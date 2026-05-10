{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Content.DraftPickHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Content.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type DraftPickAPI
  =    "api" :> "draft_picks" :> Get '[JSON] [DraftPick]
  :<|> "api" :> "draft_picks" :> ReqBody '[JSON] NewDraftPick :> PostCreated '[JSON] DraftPick
  :<|> "api" :> "draft_picks" :> Capture "id" Int :> Get '[JSON] DraftPick
  :<|> "api" :> "draft_picks" :> Capture "id" Int :> ReqBody '[JSON] NewDraftPick :> Put '[JSON] DraftPick
  :<|> "api" :> "draft_picks" :> Capture "id" Int :> ReqBody '[JSON] NewDraftPick :> Patch '[JSON] DraftPick
  :<|> "api" :> "draft_picks" :> Capture "id" Int :> DeleteNoContent

draftPickServer :: Server DraftPickAPI
draftPickServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, pick_number, pack_number, picked_at, participant_id, card_id FROM draft_picks" :: IO [DraftPick]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO draft_picks (pick_number, pack_number, picked_at, participant_id, card_id) VALUES (?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, pick_number, pack_number, picked_at, participant_id, card_id FROM draft_picks WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [DraftPick]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, pick_number, pack_number, picked_at, participant_id, card_id FROM draft_picks WHERE id = ?" (Only eid) :: IO [DraftPick]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE draft_picks SET pick_number = ?, pack_number = ?, picked_at = ?, participant_id = ?, card_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, pick_number, pack_number, picked_at, participant_id, card_id FROM draft_picks WHERE id = ?" (Only eid) :: IO [DraftPick]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM draft_picks WHERE id = ?" (Only eid)
      return NoContent

