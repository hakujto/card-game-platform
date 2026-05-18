{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Content.DraftSessionHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Content.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Content.DraftSessionService as DraftSessionSvc
import Data.Text (Text)

type DraftSessionAPI
  =    "api" :> "draft_sessions" :> Get '[JSON] [DraftSession]
  :<|> "api" :> "draft_sessions" :> ReqBody '[JSON] NewDraftSession :> PostCreated '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> Get '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> ReqBody '[JSON] NewDraftSession :> Put '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> ReqBody '[JSON] NewDraftSession :> Patch '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "start" :> Post '[JSON] NoContent
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "abandon" :> Post '[JSON] NoContent
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "complete" :> Post '[JSON] NoContent

draftSessionServer :: Server DraftSessionAPI
draftSessionServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorStart
  :<|> behaviorAbandon
  :<|> behaviorComplete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, status, draft_type, seats, created_at, completed_at, card_set_id, participants_id FROM draft_sessions" :: IO [DraftSession]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO draft_sessions (status, draft_type, seats, created_at, completed_at, card_set_id, participants_id) VALUES (?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, status, draft_type, seats, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [DraftSession]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, draft_type, seats, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE draft_sessions SET status = ?, draft_type = ?, seats = ?, created_at = ?, completed_at = ?, card_set_id = ?, participants_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, status, draft_type, seats, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM draft_sessions WHERE id = ?" (Only eid)
      return NoContent

    behaviorStart eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, draft_type, seats, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ DraftSessionSvc.start eid
          return NoContent

    behaviorAbandon eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, draft_type, seats, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ DraftSessionSvc.abandon eid
          return NoContent

    behaviorComplete eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, draft_type, seats, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ DraftSessionSvc.complete eid
          return NoContent

