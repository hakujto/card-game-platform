{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerService
  ( validatePlayer, promote, demote, record_win, record_loss, win_rate, verify, update_rating
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for Player
validatePlayer :: NewPlayer -> Either String NewPlayer
validatePlayer body = Right body

-- @invoke behavior stub (no-op)
promote :: Int -> IO Bool
promote _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
demote :: Int -> IO Bool
demote _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
record_win :: Int -> IO ()
record_win _eid = return ()

-- @invoke behavior stub (no-op)
record_loss :: Int -> IO ()
record_loss _eid = return ()

-- @invoke behavior stub (no-op)
win_rate :: Int -> IO Text
win_rate _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
verify :: Int -> IO ()
verify _eid = return ()

-- @invoke behavior stub (no-op)
update_rating :: Int -> IO ()
update_rating _eid = return ()

