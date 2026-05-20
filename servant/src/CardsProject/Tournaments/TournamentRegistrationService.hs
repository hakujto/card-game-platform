{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentRegistrationService
  ( validateTournamentRegistration, withdraw, disqualify, promote_from_waitlist
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for TournamentRegistration
validateTournamentRegistration :: NewTournamentRegistration -> Either String NewTournamentRegistration
validateTournamentRegistration body = Right body

-- @invoke behavior stub (no-op)
withdraw :: Int -> IO ()
withdraw _eid = return ()

-- @invoke behavior stub (no-op)
disqualify :: Int -> IO ()
disqualify _eid = return ()

-- @invoke behavior stub (no-op)
promote_from_waitlist :: Int -> IO ()
promote_from_waitlist _eid = return ()

