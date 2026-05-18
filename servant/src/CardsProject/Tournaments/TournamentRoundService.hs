{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentRoundService
  ( validateTournamentRound, start, complete, generate_pairings, is_time_expired
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for TournamentRound
validateTournamentRound :: NewTournamentRound -> Either String NewTournamentRound
validateTournamentRound body = Right body

-- @invoke behavior stub
start :: Int -> IO ()
start eid = do
  throwIO (userError "start not implemented")

-- @invoke behavior stub
complete :: Int -> IO ()
complete eid = do
  throwIO (userError "complete not implemented")

-- @invoke behavior stub
generate_pairings :: Int -> IO ()
generate_pairings eid = do
  throwIO (userError "generate_pairings not implemented")

-- @invoke behavior stub
is_time_expired :: Int -> IO Bool
is_time_expired eid = do
  throwIO (userError "is_time_expired not implemented")

