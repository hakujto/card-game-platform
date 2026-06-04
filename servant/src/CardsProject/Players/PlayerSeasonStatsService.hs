{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerSeasonStatsService
  ( validatePlayerSeasonStats, win_rate, add_points, record_tournament_win
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for PlayerSeasonStats
validatePlayerSeasonStats :: NewPlayerSeasonStats -> Either String NewPlayerSeasonStats
validatePlayerSeasonStats body
  | not (bPlayerSeasonStatsWins body >= 0) = Left "Season wins must not be negative"
  | not (bPlayerSeasonStatsLosses body >= 0) = Left "Season losses must not be negative"
  | not (bPlayerSeasonStatsTournamentWins body >= 0) = Left "Season tournament wins must not be negative"
  | not (bPlayerSeasonStatsSeasonPoints body >= 0) = Left "Season points must not be negative"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
win_rate :: Int -> IO Text
win_rate _eid = throwIO (userError "win_rate not implemented")

-- @invoke behavior stub (no-op)
add_points :: Int -> IO ()
add_points _eid = throwIO (userError "add_points not implemented")

-- @invoke behavior stub (no-op)
record_tournament_win :: Int -> IO ()
record_tournament_win _eid = throwIO (userError "record_tournament_win not implemented")

