{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Players.PlayerAchievementHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Players.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Players.PlayerAchievementService as PlayerAchievementSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type PlayerAchievementAPI
  =    "api" :> "player_achievements" :> Get '[JSON] [PlayerAchievement]
  :<|> "api" :> "player_achievements" :> Capture "id" Int :> Get '[JSON] PlayerAchievement
  :<|> "api" :> "player_achievements" :> Capture "id" Int :> "progress" :> ReqBody '[JSON] Object :> PatchNoContent
  :<|> "api" :> "player_achievements" :> Capture "id" Int :> "complete" :> PostNoContent

playerAchievementServer :: Server PlayerAchievementAPI
playerAchievementServer = listAll
  :<|> getOne
  :<|> behaviorIncrementProgress
  :<|> behaviorComplete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, earned_at, progress, is_completed, player_id, achievement_id FROM player_achievements" :: IO [PlayerAchievement]

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, earned_at, progress, is_completed, player_id, achievement_id FROM player_achievements WHERE id = ?" (Only eid) :: IO [PlayerAchievement]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorIncrementProgress eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, earned_at, progress, is_completed, player_id, achievement_id FROM player_achievements WHERE id = ?" (Only eid) :: IO [PlayerAchievement]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerAchievementSvc.increment_progress eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorComplete eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, earned_at, progress, is_completed, player_id, achievement_id FROM player_achievements WHERE id = ?" (Only eid) :: IO [PlayerAchievement]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerAchievementSvc.complete eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

