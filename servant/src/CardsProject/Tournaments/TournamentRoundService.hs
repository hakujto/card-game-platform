{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentRoundService
  ( validateTournamentRound, start, complete, generate_pairings, is_time_expired
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for TournamentRound
validateTournamentRound :: NewTournamentRound -> Either String NewTournamentRound
validateTournamentRound body = Right body

-- @invoke behavior stub (no-op)
start :: Int -> IO ()
start _eid = return ()

-- @invoke behavior stub (no-op)
complete :: Int -> IO ()
complete _eid = return ()

-- @invoke behavior stub (no-op)
generate_pairings :: Int -> IO ()
generate_pairings _eid = return ()

-- @invoke behavior stub (no-op)
is_time_expired :: Int -> IO Bool
is_time_expired _eid = return (error "TODO")

