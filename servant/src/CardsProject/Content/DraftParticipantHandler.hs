{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Content.DraftParticipantHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Content.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Content.DraftParticipantService as DraftParticipantSvc
import Data.Aeson (Object)
import Data.Text (Text)

type DraftParticipantAPI
  =    "api" :> "draft_participants" :> Get '[JSON] [DraftParticipant]
  :<|> "api" :> "draft_participants" :> ReqBody '[JSON] NewDraftParticipant :> PostCreated '[JSON] DraftParticipant
  :<|> "api" :> "draft_participants" :> Capture "id" Int :> Get '[JSON] DraftParticipant
  :<|> "api" :> "draft_participants" :> Capture "id" Int :> ReqBody '[JSON] NewDraftParticipant :> Put '[JSON] DraftParticipant
  :<|> "api" :> "draft_participants" :> Capture "id" Int :> ReqBody '[JSON] NewDraftParticipant :> Patch '[JSON] DraftParticipant
  :<|> "api" :> "draft_participants" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "draft_participants" :> Capture "id" Int :> "pick" :> ReqBody '[JSON] Object :> Post '[JSON] NoContent
  :<|> "api" :> "draft_participants" :> Capture "id" Int :> "card-count" :> Get '[JSON] Int

draftParticipantServer :: Server DraftParticipantAPI
draftParticipantServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorPickCard
  :<|> behaviorDraftedCardCount
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, seat_number, joined_at, session_id, player_id, drafted_cards_id FROM draft_participants" :: IO [DraftParticipant]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO draft_participants (seat_number, joined_at, session_id, player_id, drafted_cards_id) VALUES (?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, seat_number, joined_at, session_id, player_id, drafted_cards_id FROM draft_participants WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [DraftParticipant]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, seat_number, joined_at, session_id, player_id, drafted_cards_id FROM draft_participants WHERE id = ?" (Only eid) :: IO [DraftParticipant]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE draft_participants SET seat_number = ?, joined_at = ?, session_id = ?, player_id = ?, drafted_cards_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, seat_number, joined_at, session_id, player_id, drafted_cards_id FROM draft_participants WHERE id = ?" (Only eid) :: IO [DraftParticipant]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM draft_participants WHERE id = ?" (Only eid)
      return NoContent

    behaviorPickCard eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, seat_number, joined_at, session_id, player_id, drafted_cards_id FROM draft_participants WHERE id = ?" (Only eid) :: IO [DraftParticipant]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ DraftParticipantSvc.pick_card eid
          return NoContent

    behaviorDraftedCardCount eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, seat_number, joined_at, session_id, player_id, drafted_cards_id FROM draft_participants WHERE id = ?" (Only eid) :: IO [DraftParticipant]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ DraftParticipantSvc.drafted_card_count eid
          return result

