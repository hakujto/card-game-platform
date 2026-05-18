{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentJudgeService
  ( validateTournamentJudge
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)

-- Domain service stub for TournamentJudge
validateTournamentJudge :: NewTournamentJudge -> Either String NewTournamentJudge
validateTournamentJudge body = Right body

