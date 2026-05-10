{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerAchievementService where

import CardsProject.Players.Types

-- Domain service stub for PlayerAchievement
validatePlayerAchievement :: NewPlayerAchievement -> Either String NewPlayerAchievement
validatePlayerAchievement body = Right body

