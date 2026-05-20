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

-- Domain service stub for Season
validateSeason :: NewSeason -> Either String NewSeason
validateSeason body = Right body

-- @invoke behavior stub (no-op)
activate :: Int -> IO ()
activate _eid = return ()

-- @invoke behavior stub (no-op)
deactivate :: Int -> IO ()
deactivate _eid = return ()

-- @invoke behavior stub (no-op)
finalize_rewards :: Int -> IO ()
finalize_rewards _eid = return ()

-- @invoke behavior stub (no-op)
is_ongoing :: Int -> IO Bool
is_ongoing _eid = return (error "TODO")

