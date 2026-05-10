{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.MatchService where

import CardsProject.Tournaments.Types

-- Domain service stub for Match
validateMatch :: NewMatch -> Either String NewMatch
validateMatch body = Right body

