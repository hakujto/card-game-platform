{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentRegistrationService
  ( validateTournamentRegistration, withdraw, disqualify, promote_from_waitlist
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for TournamentRegistration
validateTournamentRegistration :: NewTournamentRegistration -> Either String NewTournamentRegistration
validateTournamentRegistration body
  | not (bTournamentRegistrationPointsEarned body >= 0) = Left "Points earned must not be negative"
  | otherwise = validateTournamentRegistrationImplies body

validateTournamentRegistrationImplies :: NewTournamentRegistration -> Either String NewTournamentRegistration
validateTournamentRegistrationImplies body
  | (bTournamentRegistrationFinalStanding body /= Nothing) && not (maybe True (> 0) (bTournamentRegistrationFinalStanding body)) = Left "Final standing must be greater than zero"
  | (bTournamentRegistrationSeed body /= Nothing) && not (maybe True (> 0) (bTournamentRegistrationSeed body)) = Left "Seed must be greater than zero"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
withdraw :: Int -> IO ()
withdraw _eid = throwIO (userError "withdraw not implemented")

-- @invoke behavior stub (no-op)
disqualify :: Int -> IO ()
disqualify _eid = throwIO (userError "disqualify not implemented")

-- @invoke behavior stub (no-op)
promote_from_waitlist :: Int -> IO ()
promote_from_waitlist _eid = throwIO (userError "promote_from_waitlist not implemented")

