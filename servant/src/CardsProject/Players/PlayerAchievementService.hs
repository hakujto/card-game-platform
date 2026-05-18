{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerAchievementService
  ( validatePlayerAchievement, increment_progress, complete, setIsCompleted
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for PlayerAchievement
validatePlayerAchievement :: NewPlayerAchievement -> Either String NewPlayerAchievement
validatePlayerAchievement body = Right body

-- @invoke behavior stub
increment_progress :: Int -> IO ()
increment_progress eid = do
  -- params: amount: Int -- extract from body in handler when implementing
  throwIO (userError "increment_progress not implemented")

-- @invoke behavior stub
complete :: Int -> IO ()
complete eid = do
  throwIO (userError "complete not implemented")

-- triggered by @on(is_completed = true)
setIsCompleted :: Int -> Text -> IO ()
setIsCompleted eid value = withDb $ \conn -> do
  execute conn "UPDATE player_achievements SET is_completed = ? WHERE id = ?" (value, eid)
  if value == "TRUE"
    then throwIO (userError "complete not implemented") -- @on trigger stub
    else return ()

