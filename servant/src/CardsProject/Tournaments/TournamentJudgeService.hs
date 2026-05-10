{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentJudgeService where

import CardsProject.Tournaments.Types

-- Domain service stub for TournamentJudge
validateTournamentJudge :: NewTournamentJudge -> Either String NewTournamentJudge
validateTournamentJudge body = Right body

