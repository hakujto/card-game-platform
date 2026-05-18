{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerSeasonStatsService
  ( validatePlayerSeasonStats, win_rate, add_points, record_tournament_win
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for PlayerSeasonStats
validatePlayerSeasonStats :: NewPlayerSeasonStats -> Either String NewPlayerSeasonStats
validatePlayerSeasonStats body = Right body

-- @invoke behavior stub
win_rate :: Int -> IO Text
win_rate eid = do
  throwIO (userError "win_rate not implemented")

-- @invoke behavior stub
add_points :: Int -> IO ()
add_points eid = do
  -- params: points: Int -- extract from body in handler when implementing
  throwIO (userError "add_points not implemented")

-- @invoke behavior stub
record_tournament_win :: Int -> IO ()
record_tournament_win eid = do
  throwIO (userError "record_tournament_win not implemented")

