{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerService
  ( validatePlayer, promote, demote, record_win, record_loss, win_rate, verify, update_rating
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Player
validatePlayer :: NewPlayer -> Either String NewPlayer
validatePlayer body = Right body

-- @invoke behavior stub
promote :: Int -> IO Bool
promote eid = do
  throwIO (userError "promote not implemented")

-- @invoke behavior stub
demote :: Int -> IO Bool
demote eid = do
  throwIO (userError "demote not implemented")

-- @invoke behavior stub
record_win :: Int -> IO ()
record_win eid = do
  throwIO (userError "record_win not implemented")

-- @invoke behavior stub
record_loss :: Int -> IO ()
record_loss eid = do
  throwIO (userError "record_loss not implemented")

-- @invoke behavior stub
win_rate :: Int -> IO Text
win_rate eid = do
  throwIO (userError "win_rate not implemented")

-- @invoke behavior stub
verify :: Int -> IO ()
verify eid = do
  throwIO (userError "verify not implemented")

-- @invoke behavior stub
update_rating :: Int -> IO ()
update_rating eid = do
  -- params: delta: Int -- extract from body in handler when implementing
  throwIO (userError "update_rating not implemented")

