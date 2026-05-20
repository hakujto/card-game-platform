{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.GameService
  ( validateGame, record_winner, duration_minutes
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for Game
validateGame :: NewGame -> Either String NewGame
validateGame body = Right body

-- @invoke behavior stub (no-op)
record_winner :: Int -> IO ()
record_winner _eid = return ()

-- @invoke behavior stub (no-op)
duration_minutes :: Int -> IO Text
duration_minutes _eid = return (error "TODO")

