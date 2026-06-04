{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Tournaments.SeasonHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Tournaments.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Tournaments.SeasonService as SeasonSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Text (Text)

type SeasonAPI
  =    "api" :> "seasons" :> QueryParam "q" Text :> Get '[JSON] [Season]
  :<|> "api" :> "seasons" :> ReqBody '[JSON] NewSeason :> PostCreated '[JSON] Season
  :<|> "api" :> "seasons" :> Capture "id" Int :> Get '[JSON] Season
  :<|> "api" :> "seasons" :> Capture "id" Int :> ReqBody '[JSON] NewSeason :> Put '[JSON] Season
  :<|> "api" :> "seasons" :> Capture "id" Int :> ReqBody '[JSON] NewSeason :> Patch '[JSON] Season
  :<|> "api" :> "seasons" :> Capture "id" Int :> "activate" :> PostNoContent
  :<|> "api" :> "seasons" :> Capture "id" Int :> "deactivate" :> PostNoContent
  :<|> "api" :> "seasons" :> Capture "id" Int :> "finalize" :> PostNoContent
  :<|> "api" :> "seasons" :> Capture "id" Int :> "ongoing" :> Get '[JSON] Bool

seasonServer :: Server SeasonAPI
seasonServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> behaviorActivate
  :<|> behaviorDeactivate
  :<|> behaviorFinalizeRewards
  :<|> behaviorIsOngoing
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons" :: IO [Season]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons WHERE name LIKE ?" (Only qp) :: IO [Season]

    create body = do
      case SeasonSvc.validateSeason body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO seasons (name, start_date, end_date, format, is_active, reward_description) VALUES (?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Season]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons WHERE id = ?" (Only eid) :: IO [Season]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      case SeasonSvc.validateSeason body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = toRow validBody ++ toRow (Only eid)
            execute conn "UPDATE seasons SET name = ?, start_date = ?, end_date = ?, format = ?, is_active = ?, reward_description = ? WHERE id = ?" bodyRow
            query conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons WHERE id = ?" (Only eid) :: IO [Season]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    behaviorActivate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons WHERE id = ?" (Only eid) :: IO [Season]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> SeasonSvc.activate eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDeactivate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons WHERE id = ?" (Only eid) :: IO [Season]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> SeasonSvc.deactivate eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorFinalizeRewards eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons WHERE id = ?" (Only eid) :: IO [Season]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> SeasonSvc.finalize_rewards eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorIsOngoing eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons WHERE id = ?" (Only eid) :: IO [Season]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> SeasonSvc.is_ongoing eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

