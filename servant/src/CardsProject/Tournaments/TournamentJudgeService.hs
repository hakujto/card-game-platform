{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentJudgeService
  ( validateTournamentJudge, promote_to_head, remove
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for TournamentJudge
validateTournamentJudge :: NewTournamentJudge -> Either String NewTournamentJudge
validateTournamentJudge body = Right body

-- @invoke behavior stub
promote_to_head :: Int -> IO ()
promote_to_head eid = do
  throwIO (userError "promote_to_head not implemented")

-- @invoke behavior stub
remove :: Int -> IO ()
remove eid = do
  throwIO (userError "remove not implemented")

