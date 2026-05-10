{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentService where

import CardsProject.Tournaments.Types

-- Domain service stub for Tournament
validateTournament :: NewTournament -> Either String NewTournament
validateTournament body = Right body

