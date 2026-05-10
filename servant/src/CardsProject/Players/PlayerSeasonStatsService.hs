{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerSeasonStatsService where

import CardsProject.Players.Types

-- Domain service stub for PlayerSeasonStats
validatePlayerSeasonStats :: NewPlayerSeasonStats -> Either String NewPlayerSeasonStats
validatePlayerSeasonStats body = Right body

