{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Tournaments.TournamentRoundHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Tournaments.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Tournaments.TournamentRoundService as TournamentRoundSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Text (Text)

type TournamentRoundAPI
  =    "api" :> "tournament_rounds" :> Get '[JSON] [TournamentRound]
  :<|> "api" :> "tournament_rounds" :> ReqBody '[JSON] NewTournamentRound :> PostCreated '[JSON] TournamentRound
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> Get '[JSON] TournamentRound
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> "start" :> PostNoContent
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> "complete" :> PostNoContent
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> "pairings" :> PostNoContent
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> "time-expired" :> Get '[JSON] Bool

tournamentRoundServer :: Server TournamentRoundAPI
tournamentRoundServer = listAll
  :<|> create
  :<|> getOne
  :<|> behaviorStart
  :<|> behaviorComplete
  :<|> behaviorGeneratePairings
  :<|> behaviorIsTimeExpired
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id FROM tournament_rounds" :: IO [TournamentRound]

    create body = do
      case TournamentRoundSvc.validateTournamentRound body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO tournament_rounds (round_number, status, started_at, ended_at, time_limit_minutes, tournament_id) VALUES (?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id FROM tournament_rounds WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TournamentRound]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorStart eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentRoundSvc.start eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorComplete eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentRoundSvc.complete eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorGeneratePairings eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentRoundSvc.generate_pairings eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorIsTimeExpired eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentRoundSvc.is_time_expired eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

