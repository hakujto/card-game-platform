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

-- Domain service for Player
validatePlayer :: NewPlayer -> Either String NewPlayer
validatePlayer body
  | not ((bPlayerRating body >= 0 && bPlayerRating body <= 9999)) = Left "Rating must be between 0 and 9999"
  | not (bPlayerPeakRating body >= bPlayerRating body) = Left "Peak rating must be greater than or equal to current rating"
  | not (True) = Left "Display name must not be empty"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
promote :: Int -> IO Bool
promote _eid = throwIO (userError "promote not implemented")

-- @invoke behavior stub (no-op)
demote :: Int -> IO Bool
demote _eid = throwIO (userError "demote not implemented")

-- @invoke behavior stub (no-op)
record_win :: Int -> IO ()
record_win _eid = throwIO (userError "record_win not implemented")

-- @invoke behavior stub (no-op)
record_loss :: Int -> IO ()
record_loss _eid = throwIO (userError "record_loss not implemented")

-- @invoke behavior stub (no-op)
win_rate :: Int -> IO Text
win_rate _eid = throwIO (userError "win_rate not implemented")

-- @allow [admin] — check user role before calling
-- @invoke behavior stub (no-op)
verify :: Int -> IO ()
verify _eid = throwIO (userError "verify not implemented")

-- @invoke behavior stub (no-op)
update_rating :: Int -> IO ()
update_rating _eid = throwIO (userError "update_rating not implemented")

-- ── Lifecycle hooks ─────────────────────────────────────────────────

-- TODO: implement initialize_collection
initializeCollectionHook :: a -> IO ()
initializeCollectionHook _ = return ()

-- TODO: implement update_rank
updateRankHook :: a -> IO ()
updateRankHook _ = return ()

