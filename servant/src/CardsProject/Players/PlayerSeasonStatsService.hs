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

-- Domain service stub for PlayerSeasonStats
validatePlayerSeasonStats :: NewPlayerSeasonStats -> Either String NewPlayerSeasonStats
validatePlayerSeasonStats body = Right body

-- @invoke behavior stub (no-op)
win_rate :: Int -> IO Text
win_rate _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
add_points :: Int -> IO ()
add_points _eid = return ()

-- @invoke behavior stub (no-op)
record_tournament_win :: Int -> IO ()
record_tournament_win _eid = return ()

