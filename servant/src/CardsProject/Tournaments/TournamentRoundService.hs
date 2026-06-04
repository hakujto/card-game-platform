{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentRoundService
  ( validateTournamentRound, start, complete, generate_pairings, is_time_expired
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for TournamentRound
validateTournamentRound :: NewTournamentRound -> Either String NewTournamentRound
validateTournamentRound body
  | not (bTournamentRoundRoundNumber body > 0) = Left "Round number must be greater than zero"
  | not (bTournamentRoundTimeLimitMinutes body > 0) = Left "Round time limit must be greater than zero"
  | otherwise = validateTournamentRoundImplies body

validateTournamentRoundImplies :: NewTournamentRound -> Either String NewTournamentRound
validateTournamentRoundImplies body
  | (bTournamentRoundEndedAt body /= Nothing) && not (maybe True (> (fromMaybe "" (bTournamentRoundStartedAt body))) (bTournamentRoundEndedAt body)) = Left "Round end time must be after start time"
  | (bTournamentRoundStatus body == TournamentRoundStatusType_Completed) && not (bTournamentRoundStartedAt body /= Nothing) = Left "Completed round must have a start time"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
start :: Int -> IO ()
start _eid = throwIO (userError "start not implemented")

-- @invoke behavior stub (no-op)
complete :: Int -> IO ()
complete _eid = throwIO (userError "complete not implemented")

-- @invoke behavior stub (no-op)
generate_pairings :: Int -> IO ()
generate_pairings _eid = throwIO (userError "generate_pairings not implemented")

-- @invoke behavior stub (no-op)
is_time_expired :: Int -> IO Bool
is_time_expired _eid = throwIO (userError "is_time_expired not implemented")

