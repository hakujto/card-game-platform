{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentRegistrationService where

import CardsProject.Tournaments.Types

-- Domain service stub for TournamentRegistration
validateTournamentRegistration :: NewTournamentRegistration -> Either String NewTournamentRegistration
validateTournamentRegistration body = Right body

