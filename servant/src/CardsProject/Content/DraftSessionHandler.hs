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
import qualified Data.ByteString.Lazy.Char8
import Data.Text (Text)
import Control.Exception (catch, IOException)
import Data.Text (Text)

type DraftSessionAPI
  =    "api" :> "draft_sessions" :> Get '[JSON] [DraftSession]
  :<|> "api" :> "draft_sessions" :> ReqBody '[JSON] NewDraftSession :> PostCreated '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> Get '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "start" :> PostNoContent
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "abandon" :> PostNoContent
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "complete" :> PostNoContent
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "full" :> Get '[JSON] Bool
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "transitions" :> "waitingforplayers-to-drafting" :> Patch '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "transitions" :> "drafting-to-completed" :> Patch '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "transitions" :> "drafting-to-abandoned" :> Header "X-User-Role" Text :> Patch '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "transitions" :> "waitingforplayers-to-abandoned" :> Header "X-User-Role" Text :> Patch '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "transitions" :> "completed-to-drafting" :> Patch '[JSON] DraftSession
  :<|> "api" :> "draft_sessions" :> Capture "id" Int :> "transitions" :> "abandoned-to-drafting" :> Patch '[JSON] DraftSession

draftSessionServer :: Server DraftSessionAPI
draftSessionServer = listAll
  :<|> create
  :<|> getOne
  :<|> behaviorStart
  :<|> behaviorAbandon
  :<|> behaviorComplete
  :<|> behaviorIsFull
  :<|> transitionHandlerWaitingForPlayersToDrafting
  :<|> transitionHandlerDraftingToCompleted
  :<|> transitionHandlerDraftingToAbandoned
  :<|> transitionHandlerWaitingForPlayersToAbandoned
  :<|> transitionHandlerCompletedToDrafting
  :<|> transitionHandlerAbandonedToDrafting
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id FROM draft_sessions" :: IO [DraftSession]

    create body = do
      case DraftSessionSvc.validateDraftSession body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO draft_sessions (status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id) VALUES (?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id FROM draft_sessions WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [DraftSession]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorStart eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DraftSessionSvc.start eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorAbandon eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DraftSessionSvc.abandon eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorComplete eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DraftSessionSvc.complete eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorIsFull eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DraftSessionSvc.is_full eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    transitionHandlerWaitingForPlayersToDrafting eid = do
      result <- liftIO $ (DraftSessionSvc.transitionWaitingForPlayersToDrafting eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerDraftingToCompleted eid = do
      result <- liftIO $ (DraftSessionSvc.transitionDraftingToCompleted eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerDraftingToAbandoned eid mRole = do
      let allowedRoles = ["Admin", "Organizer"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (DraftSessionSvc.transitionDraftingToAbandoned eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerWaitingForPlayersToAbandoned eid mRole = do
      let allowedRoles = ["Admin", "Organizer"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (DraftSessionSvc.transitionWaitingForPlayersToAbandoned eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerCompletedToDrafting eid = do
      result <- liftIO $ (DraftSessionSvc.transitionCompletedToDrafting eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerAbandonedToDrafting eid = do
      result <- liftIO $ (DraftSessionSvc.transitionAbandonedToDrafting eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

