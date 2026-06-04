{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.AchievementService
  ( validateAchievement, point_value, reveal
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for Achievement
validateAchievement :: NewAchievement -> Either String NewAchievement
validateAchievement body
  | not (bAchievementPoints body > 0) = Left "Achievement must award at least one point"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
point_value :: Int -> IO Int
point_value _eid = throwIO (userError "point_value not implemented")

-- @invoke behavior stub (no-op)
reveal :: Int -> IO ()
reveal _eid = throwIO (userError "reveal not implemented")

