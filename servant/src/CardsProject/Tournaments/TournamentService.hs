{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentService
  ( validateTournament, start, cancel, complete, generate_round, calculate_prize_distribution, register_player, is_full
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

-- @invoke behavior stub
register_player :: Int -> IO ()
register_player eid = do
  -- params: player_id: Int, deck_id: Int -- extract from body in handler when implementing
  throwIO (userError "register_player not implemented")

-- @invoke behavior stub
is_full :: Int -> IO Bool
is_full eid = do
  throwIO (userError "is_full not implemented")

