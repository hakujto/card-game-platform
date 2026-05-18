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
import qualified CardsProject.Tournaments.TournamentRoundService as TournamentRoundSvc
import Data.Text (Text)

type TournamentRoundAPI
  =    "api" :> "tournament_rounds" :> Get '[JSON] [TournamentRound]
  :<|> "api" :> "tournament_rounds" :> ReqBody '[JSON] NewTournamentRound :> PostCreated '[JSON] TournamentRound
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> Get '[JSON] TournamentRound
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> ReqBody '[JSON] NewTournamentRound :> Put '[JSON] TournamentRound
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> ReqBody '[JSON] NewTournamentRound :> Patch '[JSON] TournamentRound
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> "start" :> Post '[JSON] NoContent
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> "complete" :> Post '[JSON] NoContent
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> "pairings" :> Post '[JSON] NoContent
  :<|> "api" :> "tournament_rounds" :> Capture "id" Int :> "time-expired" :> Get '[JSON] Bool

tournamentRoundServer :: Server TournamentRoundAPI
tournamentRoundServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorStart
  :<|> behaviorComplete
  :<|> behaviorGeneratePairings
  :<|> behaviorIsTimeExpired
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id FROM tournament_rounds" :: IO [TournamentRound]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO tournament_rounds (round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id) VALUES (?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id FROM tournament_rounds WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TournamentRound]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE tournament_rounds SET round_number = ?, status = ?, started_at = ?, ended_at = ?, time_limit_minutes = ?, tournament_id = ?, matches_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM tournament_rounds WHERE id = ?" (Only eid)
      return NoContent

    behaviorStart eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TournamentRoundSvc.start eid
          return NoContent

    behaviorComplete eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TournamentRoundSvc.complete eid
          return NoContent

    behaviorGeneratePairings eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TournamentRoundSvc.generate_pairings eid
          return NoContent

    behaviorIsTimeExpired eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, matches_id FROM tournament_rounds WHERE id = ?" (Only eid) :: IO [TournamentRound]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ TournamentRoundSvc.is_time_expired eid
          return result

