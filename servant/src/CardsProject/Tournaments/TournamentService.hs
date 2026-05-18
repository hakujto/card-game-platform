{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentService
  ( validateTournament, start, cancel, complete, generate_round, calculate_prize_distribution, is_full
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Tournament
validateTournament :: NewTournament -> Either String NewTournament
validateTournament body = Right body

-- @invoke behavior stub
start :: Int -> IO ()
start eid = do
  throwIO (userError "start not implemented")

-- @invoke behavior stub
cancel :: Int -> IO ()
cancel eid = do
  throwIO (userError "cancel not implemented")

-- @invoke behavior stub
complete :: Int -> IO ()
complete eid = do
  throwIO (userError "complete not implemented")

-- @invoke behavior stub
generate_round :: Int -> IO ()
generate_round eid = do
  throwIO (userError "generate_round not implemented")

-- @invoke behavior stub
calculate_prize_distribution :: Int -> IO Text
calculate_prize_distribution eid = do
  throwIO (userError "calculate_prize_distribution not implemented")

-- domain behavior stub
is_full :: IO Bool
is_full  =
  throwIO (userError "is_full not implemented")

