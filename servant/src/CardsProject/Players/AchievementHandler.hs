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
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Text (Text)

type AchievementAPI
  =    "api" :> "achievements" :> QueryParam "q" Text :> Get '[JSON] [Achievement]
  :<|> "api" :> "achievements" :> ReqBody '[JSON] NewAchievement :> PostCreated '[JSON] Achievement
  :<|> "api" :> "achievements" :> Capture "id" Int :> Get '[JSON] Achievement
  :<|> "api" :> "achievements" :> Capture "id" Int :> ReqBody '[JSON] NewAchievement :> Put '[JSON] Achievement
  :<|> "api" :> "achievements" :> Capture "id" Int :> ReqBody '[JSON] NewAchievement :> Patch '[JSON] Achievement
  :<|> "api" :> "achievements" :> Capture "id" Int :> "point-value" :> Get '[JSON] Int
  :<|> "api" :> "achievements" :> Capture "id" Int :> "reveal" :> PostNoContent

achievementServer :: Server AchievementAPI
achievementServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> behaviorPointValue
  :<|> behaviorReveal
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements" :: IO [Achievement]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements WHERE name LIKE ? OR description LIKE ?" ((qp, qp)) :: IO [Achievement]

    create body = do
      case AchievementSvc.validateAchievement body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO achievements (name, description, icon_url, points, rarity, is_hidden) VALUES (?, ?, ?, ?, ?, ?)" validBody
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
      case AchievementSvc.validateAchievement body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = toRow validBody ++ toRow (Only eid)
            execute conn "UPDATE achievements SET name = ?, description = ?, icon_url = ?, points = ?, rarity = ?, is_hidden = ? WHERE id = ?" bodyRow
            query conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements WHERE id = ?" (Only eid) :: IO [Achievement]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    behaviorPointValue eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements WHERE id = ?" (Only eid) :: IO [Achievement]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> AchievementSvc.point_value eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorReveal eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, icon_url, points, rarity, is_hidden FROM achievements WHERE id = ?" (Only eid) :: IO [Achievement]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> AchievementSvc.reveal eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

