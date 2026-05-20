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

-- Domain service stub for Achievement
validateAchievement :: NewAchievement -> Either String NewAchievement
validateAchievement body = Right body

-- @invoke behavior stub (no-op)
point_value :: Int -> IO Int
point_value _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
reveal :: Int -> IO ()
reveal _eid = return ()

