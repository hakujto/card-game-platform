{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentPrizeService where

import CardsProject.Tournaments.Types

-- Domain service stub for TournamentPrize
validateTournamentPrize :: NewTournamentPrize -> Either String NewTournamentPrize
validateTournamentPrize body = Right body

