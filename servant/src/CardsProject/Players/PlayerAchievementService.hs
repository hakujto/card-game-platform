{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerAchievementService
  ( validatePlayerAchievement
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)

-- Domain service stub for PlayerAchievement
validatePlayerAchievement :: NewPlayerAchievement -> Either String NewPlayerAchievement
validatePlayerAchievement body = Right body

