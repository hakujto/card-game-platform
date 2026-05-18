{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentRegistrationService
  ( validateTournamentRegistration, withdraw, disqualify, promote_from_waitlist
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for TournamentRegistration
validateTournamentRegistration :: NewTournamentRegistration -> Either String NewTournamentRegistration
validateTournamentRegistration body = Right body

-- @invoke behavior stub
withdraw :: Int -> IO ()
withdraw eid = do
  throwIO (userError "withdraw not implemented")

-- @invoke behavior stub
disqualify :: Int -> IO ()
disqualify eid = do
  -- params: reason: String -- extract from body in handler when implementing
  throwIO (userError "disqualify not implemented")

-- @invoke behavior stub
promote_from_waitlist :: Int -> IO ()
promote_from_waitlist eid = do
  throwIO (userError "promote_from_waitlist not implemented")

