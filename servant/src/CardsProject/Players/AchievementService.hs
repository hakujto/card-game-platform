{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.AchievementService where

import CardsProject.Players.Types

-- Domain service stub for Achievement
validateAchievement :: NewAchievement -> Either String NewAchievement
validateAchievement body = Right body

