{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.SeasonService
  ( validateSeason, activate, deactivate, finalize_rewards, is_ongoing
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for Season
validateSeason :: NewSeason -> Either String NewSeason
validateSeason body
  | not (bSeasonEndDate body > bSeasonStartDate body) = Left "Season end date must be after start date"
  | otherwise = Right body

-- @allow [admin] — check user role before calling
-- @invoke behavior stub (no-op)
activate :: Int -> IO ()
activate _eid = throwIO (userError "activate not implemented")

-- @allow [admin] — check user role before calling
-- @invoke behavior stub (no-op)
deactivate :: Int -> IO ()
deactivate _eid = throwIO (userError "deactivate not implemented")

-- @allow [admin] — check user role before calling
-- @invoke behavior stub (no-op)
finalize_rewards :: Int -> IO ()
finalize_rewards _eid = throwIO (userError "finalize_rewards not implemented")

-- @invoke behavior stub (no-op)
is_ongoing :: Int -> IO Bool
is_ongoing _eid = throwIO (userError "is_ongoing not implemented")

