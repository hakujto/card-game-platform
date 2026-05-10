{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentRoundService where

import CardsProject.Tournaments.Types

-- Domain service stub for TournamentRound
validateTournamentRound :: NewTournamentRound -> Either String NewTournamentRound
validateTournamentRound body = Right body

