{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Tournaments.MatchHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Tournaments.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Tournaments.MatchService as MatchSvc
import qualified Data.ByteString.Lazy.Char8
import Data.Text (Text)
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type MatchAPI
  =    "api" :> "matches" :> Get '[JSON] [Match]
  :<|> "api" :> "matches" :> ReqBody '[JSON] NewMatch :> PostCreated '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> Get '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> "record" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "matches" :> Capture "id" Int :> "finalize" :> PostNoContent
  :<|> "api" :> "matches" :> Capture "id" Int :> "winner" :> Get '[JSON] Bool
  :<|> "api" :> "matches" :> Capture "id" Int :> "concede" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "matches" :> Capture "id" Int :> "draw" :> PostNoContent
  :<|> "api" :> "matches" :> Capture "id" Int :> "transitions" :> "pending-to-active" :> Patch '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> "transitions" :> "active-to-completed" :> Patch '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> "transitions" :> "active-to-draw" :> Patch '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> "transitions" :> "pending-to-bye" :> Patch '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> "transitions" :> "completed-to-active" :> Patch '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> "transitions" :> "draw-to-active" :> Patch '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> "transitions" :> "bye-to-active" :> Patch '[JSON] Match

matchServer :: Server MatchAPI
matchServer = listAll
  :<|> create
  :<|> getOne
  :<|> behaviorRecordResult
  :<|> behaviorFinalizeResult
  :<|> behaviorDetermineWinner
  :<|> behaviorConcede
  :<|> behaviorDraw
  :<|> transitionHandlerPendingToActive
  :<|> transitionHandlerActiveToCompleted
  :<|> transitionHandlerActiveToDraw
  :<|> transitionHandlerPendingToBYE
  :<|> transitionHandlerCompletedToActive
  :<|> transitionHandlerDrawToActive
  :<|> transitionHandlerBYEToActive
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches" :: IO [Match]

    create body = do
      case MatchSvc.validateMatch body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO matches (table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Match]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorRecordResult eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> MatchSvc.record_result eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorFinalizeResult eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> MatchSvc.finalize_result eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDetermineWinner eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> MatchSvc.determine_winner eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorConcede eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> MatchSvc.concede eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDraw eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> MatchSvc.draw eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    transitionHandlerPendingToActive eid = do
      result <- liftIO $ (MatchSvc.transitionPendingToActive eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerActiveToCompleted eid = do
      result <- liftIO $ (MatchSvc.transitionActiveToCompleted eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerActiveToDraw eid = do
      result <- liftIO $ (MatchSvc.transitionActiveToDraw eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerPendingToBYE eid = do
      result <- liftIO $ (MatchSvc.transitionPendingToBYE eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerCompletedToActive eid = do
      result <- liftIO $ (MatchSvc.transitionCompletedToActive eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerDrawToActive eid = do
      result <- liftIO $ (MatchSvc.transitionDrawToActive eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerBYEToActive eid = do
      result <- liftIO $ (MatchSvc.transitionBYEToActive eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

