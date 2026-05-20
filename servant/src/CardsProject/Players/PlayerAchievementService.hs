{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerAchievementService
  ( validatePlayerAchievement, increment_progress, complete, setIsCompleted
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for PlayerAchievement
validatePlayerAchievement :: NewPlayerAchievement -> Either String NewPlayerAchievement
validatePlayerAchievement body = Right body

-- @invoke behavior stub (no-op)
increment_progress :: Int -> IO ()
increment_progress _eid = return ()

-- @invoke behavior stub (no-op)
complete :: Int -> IO ()
complete _eid = return ()

-- triggered by @on(is_completed = true)
setIsCompleted :: Int -> Text -> IO ()
setIsCompleted eid value = withDb $ \conn -> do
  execute conn "UPDATE player_achievements SET is_completed = ? WHERE id = ?" (value, eid)
  if value == "TRUE"
    then return () -- TODO: complete @on trigger
    else return ()

