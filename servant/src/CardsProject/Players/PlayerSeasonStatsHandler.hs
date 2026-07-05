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
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Players.PlayerSeasonStatsService as PlayerSeasonStatsSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type PlayerSeasonStatsAPI
  =    "api" :> "player_season_statses" :> Get '[JSON] [PlayerSeasonStats]
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> Get '[JSON] PlayerSeasonStats
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> "win-rate" :> Get '[JSON] Text
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> "points" :> ReqBody '[JSON] Object :> PatchNoContent
  :<|> "api" :> "player_season_statses" :> Capture "id" Int :> "tournament-win" :> PostNoContent

playerSeasonStatsServer :: Server PlayerSeasonStatsAPI
playerSeasonStatsServer = listAll
  :<|> getOne
  :<|> behaviorWinRate
  :<|> behaviorAddPoints
  :<|> behaviorRecordTournamentWin
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses" :: IO [PlayerSeasonStats]

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses WHERE id = ?" (Only eid) :: IO [PlayerSeasonStats]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorWinRate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses WHERE id = ?" (Only eid) :: IO [PlayerSeasonStats]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerSeasonStatsSvc.win_rate eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorAddPoints eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses WHERE id = ?" (Only eid) :: IO [PlayerSeasonStats]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerSeasonStatsSvc.add_points eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorRecordTournamentWin eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id FROM player_season_statses WHERE id = ?" (Only eid) :: IO [PlayerSeasonStats]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerSeasonStatsSvc.record_tournament_win eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

