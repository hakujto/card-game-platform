{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Tournaments.TournamentHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Tournaments.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Tournaments.TournamentService as TournamentSvc
import qualified Data.ByteString.Lazy.Char8
import Data.Text (Text)
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type TournamentAPI
  =    "api" :> "tournaments" :> QueryParam "q" Text :> Get '[JSON] [Tournament]
  :<|> "api" :> "tournaments" :> ReqBody '[JSON] NewTournament :> PostCreated '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> Get '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> ReqBody '[JSON] NewTournament :> Put '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> ReqBody '[JSON] NewTournament :> Patch '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "start" :> PostNoContent
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "cancel" :> PostNoContent
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "complete" :> PostNoContent
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "rounds" :> PostNoContent
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "prizes" :> Get '[JSON] Text
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "register" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "full" :> Get '[JSON] Bool
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "transitions" :> "draft-to-registration" :> Patch '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "transitions" :> "registration-to-ongoing" :> Patch '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "transitions" :> "registration-to-cancelled" :> Patch '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "transitions" :> "ongoing-to-completed" :> Patch '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "transitions" :> "ongoing-to-cancelled" :> Patch '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "transitions" :> "completed-to-draft" :> Patch '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "transitions" :> "cancelled-to-draft" :> Patch '[JSON] Tournament

tournamentServer :: Server TournamentAPI
tournamentServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> behaviorStart
  :<|> behaviorCancel
  :<|> behaviorComplete
  :<|> behaviorGenerateRound
  :<|> behaviorCalculatePrizeDistribution
  :<|> behaviorRegisterPlayer
  :<|> behaviorIsFull
  :<|> transitionHandlerDraftToRegistration
  :<|> transitionHandlerRegistrationToOngoing
  :<|> transitionHandlerRegistrationToCancelled
  :<|> transitionHandlerOngoingToCompleted
  :<|> transitionHandlerOngoingToCancelled
  :<|> transitionHandlerCompletedToDraft
  :<|> transitionHandlerCancelledToDraft
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments" :: IO [Tournament]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE name LIKE ? OR description LIKE ?" ((qp, qp)) :: IO [Tournament]

    create body = do
      case TournamentSvc.validateTournament body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO tournaments (name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Tournament]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      case TournamentSvc.validateTournament body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = toRow validBody ++ toRow (Only eid)
            execute conn "UPDATE tournaments SET name = ?, description = ?, status = ?, format = ?, tournament_type = ?, max_players = ?, entry_fee = ?, prize_pool = ?, start_time = ?, end_time = ?, is_online = ?, location = ?, rules_text = ?, created_at = ?, season_id = ?, organizer_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    behaviorStart eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentSvc.start eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorCancel eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentSvc.cancel eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorComplete eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentSvc.complete eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorGenerateRound eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentSvc.generate_round eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorCalculatePrizeDistribution eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentSvc.calculate_prize_distribution eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorRegisterPlayer eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentSvc.register_player eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorIsFull eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentSvc.is_full eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    transitionHandlerDraftToRegistration eid = do
      result <- liftIO $ (TournamentSvc.transitionDraftToRegistration eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerRegistrationToOngoing eid = do
      result <- liftIO $ (TournamentSvc.transitionRegistrationToOngoing eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerRegistrationToCancelled eid = do
      result <- liftIO $ (TournamentSvc.transitionRegistrationToCancelled eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerOngoingToCompleted eid = do
      result <- liftIO $ (TournamentSvc.transitionOngoingToCompleted eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerOngoingToCancelled eid = do
      result <- liftIO $ (TournamentSvc.transitionOngoingToCancelled eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerCompletedToDraft eid = do
      result <- liftIO $ (TournamentSvc.transitionCompletedToDraft eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerCancelledToDraft eid = do
      result <- liftIO $ (TournamentSvc.transitionCancelledToDraft eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

