{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.AchievementService
  ( validateAchievement, point_value, reveal
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Achievement
validateAchievement :: NewAchievement -> Either String NewAchievement
validateAchievement body = Right body

-- @invoke behavior stub
point_value :: Int -> IO Int
point_value eid = do
  -- params: multiplier: Int -- extract from body in handler when implementing
  throwIO (userError "point_value not implemented")

-- @invoke behavior stub
reveal :: Int -> IO ()
reveal eid = do
  throwIO (userError "reveal not implemented")

