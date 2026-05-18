{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Players.PlayerSeasonStatsHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Players.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Players.PlayerSeasonStatsService as PlayerSeasonStatsSvc
import Data.Aeson (Object)
import Data.Text (Text)

type PlayerSeasonStatsAPI
  =    "api" :> "player_season_statses" :> Get '[JSON] [PlayerSeasonStats]
  :<|> "api" :> "player_season_statses" :> ReqBody '[JSON] NewPlayerSeasonStats :> PostCreated '[JSON] PlayerSeasonStats
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> Get '[JSON] PlayerSeasonStats
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> ReqBody '[JSON] NewPlayerSeasonStats :> Put '[JSON] PlayerSeasonStats
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> ReqBody '[JSON] NewPlayerSeasonStats :> Patch '[JSON] PlayerSeasonStats
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> "win-rate" :> Get '[JSON] Text
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> "points" :> ReqBody '[JSON] Object :> Patch '[JSON] NoContent
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> "tournament-win" :> Post '[JSON] NoContent

playerSeasonStatsServer :: Server PlayerSeasonStatsAPI
playerSeasonStatsServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorWinRate
  :<|> behaviorAddPoints
  :<|> behaviorRecordTournamentWin
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses" :: IO [PlayerSeasonStats]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO player_season_statses (wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [PlayerSeasonStats]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses WHERE id = ?" (Only eid) :: IO [PlayerSeasonStats]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE player_season_statses SET wins = ?, losses = ?, draws = ?, tournament_wins = ?, highest_rank = ?, season_points = ?, player_id = ?, season_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses WHERE id = ?" (Only eid) :: IO [PlayerSeasonStats]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM player_season_statses WHERE id = ?" (Only eid)
      return NoContent

    behaviorWinRate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses WHERE id = ?" (Only eid) :: IO [PlayerSeasonStats]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ PlayerSeasonStatsSvc.win_rate eid
          return result

    behaviorAddPoints eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses WHERE id = ?" (Only eid) :: IO [PlayerSeasonStats]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ PlayerSeasonStatsSvc.add_points eid
          return NoContent

    behaviorRecordTournamentWin eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses WHERE id = ?" (Only eid) :: IO [PlayerSeasonStats]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ PlayerSeasonStatsSvc.record_tournament_win eid
          return NoContent

