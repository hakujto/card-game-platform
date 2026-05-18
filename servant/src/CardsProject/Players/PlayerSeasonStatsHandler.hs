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

type PlayerSeasonStatsAPI
  =    "api" :> "player_season_statses" :> Get '[JSON] [PlayerSeasonStats]
  :<|> "api" :> "player_season_statses" :> ReqBody '[JSON] NewPlayerSeasonStats :> PostCreated '[JSON] PlayerSeasonStats
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> Get '[JSON] PlayerSeasonStats
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> ReqBody '[JSON] NewPlayerSeasonStats :> Put '[JSON] PlayerSeasonStats
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> ReqBody '[JSON] NewPlayerSeasonStats :> Patch '[JSON] PlayerSeasonStats
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> DeleteNoContent

playerSeasonStatsServer :: Server PlayerSeasonStatsAPI
playerSeasonStatsServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
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

