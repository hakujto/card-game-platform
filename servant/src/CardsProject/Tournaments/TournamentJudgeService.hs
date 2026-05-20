{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentJudgeService
  ( validateTournamentJudge, promote_to_head, remove
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for TournamentJudge
validateTournamentJudge :: NewTournamentJudge -> Either String NewTournamentJudge
validateTournamentJudge body = Right body

-- @invoke behavior stub (no-op)
promote_to_head :: Int -> IO ()
promote_to_head _eid = return ()

-- @invoke behavior stub (no-op)
remove :: Int -> IO ()
remove _eid = return ()

