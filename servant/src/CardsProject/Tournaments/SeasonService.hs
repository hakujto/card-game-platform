{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.SeasonService
  ( validateSeason, activate, deactivate, finalize_rewards, is_ongoing
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Season
validateSeason :: NewSeason -> Either String NewSeason
validateSeason body = Right body

-- @invoke behavior stub
activate :: Int -> IO ()
activate eid = do
  throwIO (userError "activate not implemented")

-- @invoke behavior stub
deactivate :: Int -> IO ()
deactivate eid = do
  throwIO (userError "deactivate not implemented")

-- @invoke behavior stub
finalize_rewards :: Int -> IO ()
finalize_rewards eid = do
  throwIO (userError "finalize_rewards not implemented")

-- domain behavior stub
is_ongoing :: IO Bool
is_ongoing  =
  throwIO (userError "is_ongoing not implemented")

