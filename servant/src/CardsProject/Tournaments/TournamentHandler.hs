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
import Data.Text (Text)

type TournamentAPI
  =    "api" :> "tournaments" :> Get '[JSON] [Tournament]
  :<|> "api" :> "tournaments" :> ReqBody '[JSON] NewTournament :> PostCreated '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> Get '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> ReqBody '[JSON] NewTournament :> Put '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> ReqBody '[JSON] NewTournament :> Patch '[JSON] Tournament
  :<|> "api" :> "tournaments" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "start" :> Post '[JSON] NoContent
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "cancel" :> Post '[JSON] NoContent
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "complete" :> Post '[JSON] NoContent
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "rounds" :> Post '[JSON] NoContent
  :<|> "api" :> "tournaments" :> Capture "id" Int :> "prizes" :> Get '[JSON] Text

tournamentServer :: Server TournamentAPI
tournamentServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorStart
  :<|> behaviorCancel
  :<|> behaviorComplete
  :<|> behaviorGenerateRound
  :<|> behaviorCalculatePrizeDistribution
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments" :: IO [Tournament]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO tournaments (name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Tournament]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE tournaments SET name = ?, description = ?, format = ?, tournament_type = ?, status = ?, max_players = ?, entry_fee = ?, prize_pool = ?, start_time = ?, end_time = ?, is_online = ?, location = ?, rules_text = ?, created_at = ?, season_id = ?, organizer_id = ?, registrations_id = ?, rounds_id = ?, prizes_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM tournaments WHERE id = ?" (Only eid)
      return NoContent

    behaviorStart eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TournamentSvc.start eid
          return NoContent

    behaviorCancel eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TournamentSvc.cancel eid
          return NoContent

    behaviorComplete eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TournamentSvc.complete eid
          return NoContent

    behaviorGenerateRound eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TournamentSvc.generate_round eid
          return NoContent

    behaviorCalculatePrizeDistribution eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, tournament_type, status, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ TournamentSvc.calculate_prize_distribution eid
          return result

