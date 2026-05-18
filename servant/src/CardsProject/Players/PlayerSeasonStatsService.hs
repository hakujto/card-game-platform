{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerSeasonStatsService
  ( validatePlayerSeasonStats, win_rate, add_points, record_tournament_win
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for PlayerSeasonStats
validatePlayerSeasonStats :: NewPlayerSeasonStats -> Either String NewPlayerSeasonStats
validatePlayerSeasonStats body = Right body

-- domain behavior stub
win_rate :: IO Text
win_rate  =
  throwIO (userError "win_rate not implemented")

-- domain behavior stub
add_points :: Int -> IO ()
add_points _points =
  throwIO (userError "add_points not implemented")

-- domain behavior stub
record_tournament_win :: IO ()
record_tournament_win  =
  throwIO (userError "record_tournament_win not implemented")

