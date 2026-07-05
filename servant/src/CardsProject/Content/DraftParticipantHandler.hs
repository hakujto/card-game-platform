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
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Content.DraftParticipantService as DraftParticipantSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type DraftParticipantAPI
  =    "api" :> "draft_participants" :> Get '[JSON] [DraftParticipant]
  :<|> "api" :> "draft_participants" :> ReqBody '[JSON] NewDraftParticipant :> PostCreated '[JSON] DraftParticipant
  :<|> "api" :> "draft_participants" :> Capture "id" Int :> Get '[JSON] DraftParticipant
  :<|> "api" :> "draft_participants" :> Capture "id" Int :> "pick" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "draft_participants" :> Capture "id" Int :> "card-count" :> Get '[JSON] Int

draftParticipantServer :: Server DraftParticipantAPI
draftParticipantServer = listAll
  :<|> create
  :<|> getOne
  :<|> behaviorPickCard
  :<|> behaviorDraftedCardCount
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, seat_number, joined_at, session_id, player_id FROM draft_participants" :: IO [DraftParticipant]

    create body = do
      case DraftParticipantSvc.validateDraftParticipant body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO draft_participants (seat_number, joined_at, session_id, player_id) VALUES (?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, seat_number, joined_at, session_id, player_id FROM draft_participants WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [DraftParticipant]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, seat_number, joined_at, session_id, player_id FROM draft_participants WHERE id = ?" (Only eid) :: IO [DraftParticipant]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorPickCard eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, seat_number, joined_at, session_id, player_id FROM draft_participants WHERE id = ?" (Only eid) :: IO [DraftParticipant]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DraftParticipantSvc.pick_card eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDraftedCardCount eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, seat_number, joined_at, session_id, player_id FROM draft_participants WHERE id = ?" (Only eid) :: IO [DraftParticipant]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DraftParticipantSvc.drafted_card_count eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

