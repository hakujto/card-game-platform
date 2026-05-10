{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.SeasonService where

import CardsProject.Tournaments.Types

-- Domain service stub for Season
validateSeason :: NewSeason -> Either String NewSeason
validateSeason body = Right body

