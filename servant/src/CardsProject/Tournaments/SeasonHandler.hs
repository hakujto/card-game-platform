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

type SeasonAPI
  =    "api" :> "seasons" :> Get '[JSON] [Season]
  :<|> "api" :> "seasons" :> ReqBody '[JSON] NewSeason :> PostCreated '[JSON] Season
  :<|> "api" :> "seasons" :> Capture "id" Int :> Get '[JSON] Season
  :<|> "api" :> "seasons" :> Capture "id" Int :> ReqBody '[JSON] NewSeason :> Put '[JSON] Season
  :<|> "api" :> "seasons" :> Capture "id" Int :> ReqBody '[JSON] NewSeason :> Patch '[JSON] Season
  :<|> "api" :> "seasons" :> Capture "id" Int :> DeleteNoContent

seasonServer :: Server SeasonAPI
seasonServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons" :: IO [Season]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO seasons (name, start_date, end_date, format, is_active, reward_description) VALUES (?, ?, ?, ?, ?, ?)" body
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
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE seasons SET name = ?, start_date = ?, end_date = ?, format = ?, is_active = ?, reward_description = ? WHERE id = ?" bodyRow
        query conn "SELECT id, name, start_date, end_date, format, is_active, reward_description FROM seasons WHERE id = ?" (Only eid) :: IO [Season]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM seasons WHERE id = ?" (Only eid)
      return NoContent

