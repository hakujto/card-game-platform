{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Players.AchievementHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Players.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Players.AchievementService as AchievementSvc
import Data.Text (Text)

type AchievementAPI
  =    "api" :> "achievements" :> Get '[JSON] [Achievement]
  :<|> "api" :> "achievements" :> ReqBody '[JSON] NewAchievement :> PostCreated '[JSON] Achievement
  :<|> "api" :> "achievements" :> Capture "id" Int :> Get '[JSON] Achievement
  :<|> "api" :> "achievements" :> Capture "id" Int :> ReqBody '[JSON] NewAchievement :> Put '[JSON] Achievement
  :<|> "api" :> "achievements" :> Capture "id" Int :> ReqBody '[JSON] NewAchievement :> Patch '[JSON] Achievement
  :<|> "api" :> "achievements" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "achievements" :> Capture "id" Int :> "point-value" :> Get '[JSON] Int
  :<|> "api" :> "achievements" :> Capture "id" Int :> "reveal" :> Post '[JSON] NoContent

achievementServer :: Server AchievementAPI
achievementServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorPointValue
  :<|> behaviorReveal
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements" :: IO [Achievement]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO achievements (name, description, icon_url, points, rarity, is_hidden) VALUES (?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Achievement]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements WHERE id = ?" (Only eid) :: IO [Achievement]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE achievements SET name = ?, description = ?, icon_url = ?, points = ?, rarity = ?, is_hidden = ? WHERE id = ?" bodyRow
        query conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements WHERE id = ?" (Only eid) :: IO [Achievement]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM achievements WHERE id = ?" (Only eid)
      return NoContent

    behaviorPointValue eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements WHERE id = ?" (Only eid) :: IO [Achievement]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ AchievementSvc.point_value eid
          return result

    behaviorReveal eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements WHERE id = ?" (Only eid) :: IO [Achievement]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ AchievementSvc.reveal eid
          return NoContent

