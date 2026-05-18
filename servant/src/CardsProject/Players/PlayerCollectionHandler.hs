{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Players.PlayerCollectionHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Players.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Players.PlayerCollectionService as PlayerCollectionSvc
import Data.Aeson (Object)
import Data.Text (Text)

type PlayerCollectionAPI
  =    "api" :> "player_collections" :> Get '[JSON] [PlayerCollection]
  :<|> "api" :> "player_collections" :> ReqBody '[JSON] NewPlayerCollection :> PostCreated '[JSON] PlayerCollection
  :<|> "api" :> "player_collections" :> Capture "id" Int :> Get '[JSON] PlayerCollection
  :<|> "api" :> "player_collections" :> Capture "id" Int :> ReqBody '[JSON] NewPlayerCollection :> Put '[JSON] PlayerCollection
  :<|> "api" :> "player_collections" :> Capture "id" Int :> ReqBody '[JSON] NewPlayerCollection :> Patch '[JSON] PlayerCollection
  :<|> "api" :> "player_collections" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "player_collections" :> Capture "id" Int :> "add" :> ReqBody '[JSON] Object :> Post '[JSON] NoContent
  :<|> "api" :> "player_collections" :> Capture "id" Int :> "remove" :> ReqBody '[JSON] Object :> Post '[JSON] NoContent
  :<|> "api" :> "player_collections" :> Capture "id" Int :> "value" :> Get '[JSON] Text

playerCollectionServer :: Server PlayerCollectionAPI
playerCollectionServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorAdd
  :<|> behaviorRemove
  :<|> behaviorEstimatedValue
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections" :: IO [PlayerCollection]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO player_collections (quantity, foil, condition, acquired_at, acquired_via, player_id, card_id) VALUES (?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [PlayerCollection]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE player_collections SET quantity = ?, foil = ?, condition = ?, acquired_at = ?, acquired_via = ?, player_id = ?, card_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM player_collections WHERE id = ?" (Only eid)
      return NoContent

    behaviorAdd eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ PlayerCollectionSvc.add eid
          return NoContent

    behaviorRemove eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ PlayerCollectionSvc.remove eid
          return NoContent

    behaviorEstimatedValue eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ PlayerCollectionSvc.estimated_value eid
          return result

