{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.AchievementService
  ( validateAchievement
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)

-- Domain service stub for Achievement
validateAchievement :: NewAchievement -> Either String NewAchievement
validateAchievement body = Right body

