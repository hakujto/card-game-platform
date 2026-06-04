{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerAchievementService
  ( validatePlayerAchievement, increment_progress, complete, setIsCompleted
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for PlayerAchievement
validatePlayerAchievement :: NewPlayerAchievement -> Either String NewPlayerAchievement
validatePlayerAchievement body
  | not (bPlayerAchievementProgress body >= 0) = Left "Achievement progress must not be negative"
  | otherwise = validatePlayerAchievementImplies body

validatePlayerAchievementImplies :: NewPlayerAchievement -> Either String NewPlayerAchievement
validatePlayerAchievementImplies body
  | (bPlayerAchievementIsCompleted body == True) && not (bPlayerAchievementProgress body > 0) = Left "Completed achievement must have progress greater than zero"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
increment_progress :: Int -> IO ()
increment_progress _eid = throwIO (userError "increment_progress not implemented")

-- @invoke behavior stub (no-op)
complete :: Int -> IO ()
complete _eid = throwIO (userError "complete not implemented")

-- triggered by @on(is_completed = true)
setIsCompleted :: Int -> Text -> IO ()
setIsCompleted eid value = withDb $ \conn -> do
  execute conn "UPDATE player_achievements SET is_completed = ? WHERE id = ?" (value, eid)
  if value == "true"
    then return () -- TODO: complete @on trigger
    else return ()

