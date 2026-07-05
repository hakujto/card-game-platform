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
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Players.PlayerCollectionService as PlayerCollectionSvc
import qualified Data.ByteString.Lazy.Char8
import Data.Text (Text)
import qualified Data.Text
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type PlayerCollectionAPI
  =    "api" :> "player_collections" :> Get '[JSON] [PlayerCollection]
  :<|> "api" :> "player_collections" :> ReqBody '[JSON] NewPlayerCollection :> PostCreated '[JSON] PlayerCollection
  :<|> "api" :> "player_collections" :> Capture "id" Int :> Header "X-User-Id" Text :> Get '[JSON] PlayerCollection
  :<|> "api" :> "player_collections" :> Capture "id" Int :> ReqBody '[JSON] NewPlayerCollection :> Header "X-User-Id" Text :> Patch '[JSON] PlayerCollection
  :<|> "api" :> "player_collections" :> Capture "id" Int :> Header "X-User-Id" Text :> DeleteNoContent
  :<|> "api" :> "player_collections" :> Capture "id" Int :> "add" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "player_collections" :> Capture "id" Int :> "remove" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "player_collections" :> Capture "id" Int :> "value" :> Get '[JSON] Text

playerCollectionServer :: Server PlayerCollectionAPI
playerCollectionServer = listAll
  :<|> create
  :<|> getOne
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorAdd
  :<|> behaviorRemove
  :<|> behaviorEstimatedValue
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections" :: IO [PlayerCollection]

    create body = do
      case PlayerCollectionSvc.validatePlayerCollection body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO player_collections (quantity, foil, condition, acquired_at, acquired_via, player_id, card_id) VALUES (?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [PlayerCollection]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid mUserId = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case rows of
        (r:_) -> case mUserId of
          Nothing  -> throwError err401
          Just uid -> if playerCollectionPlayerId r /= Just (read (Data.Text.unpack uid) :: Int)
            then throwError err403
            else return r
        []    -> throwError err404

    partialUpdate eid body mUserId = do
      ownerRows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case ownerRows of
        [] -> throwError err404
        (existing:_) -> do
          case mUserId of
            Nothing  -> throwError err401
            Just uid -> if playerCollectionPlayerId existing /= Just (read (Data.Text.unpack uid) :: Int)
              then throwError err403
              else do
                case PlayerCollectionSvc.validatePlayerCollection body of
                  Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
                  Right validBody -> do
                    rows <- liftIO $ withDb $ \conn -> do
                      let bodyRow = [toField (bPlayerCollectionQuantity validBody), toField (bPlayerCollectionFoil validBody), toField (bPlayerCollectionCondition validBody), toField (bPlayerCollectionAcquiredAt validBody), toField (bPlayerCollectionAcquiredVia validBody), toField (bPlayerCollectionPlayerId validBody), toField (bPlayerCollectionCardId validBody), toField eid]
                      execute conn "UPDATE player_collections SET quantity = ?, foil = ?, condition = ?, acquired_at = ?, acquired_via = ?, player_id = ?, card_id = ? WHERE id = ?" bodyRow
                      query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
                    case rows of
                      (r:_) -> return r
                      []    -> throwError err404

    delete eid mUserId = do
      ownerRows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case ownerRows of
        [] -> throwError err404
        (existing:_) -> do
          case mUserId of
            Nothing  -> throwError err401
            Just uid -> if playerCollectionPlayerId existing /= Just (read (Data.Text.unpack uid) :: Int)
              then throwError err403
              else do
                liftIO $ withDb $ \conn ->
                  execute conn "DELETE FROM player_collections WHERE id = ?" (Only eid)
                return NoContent

    behaviorAdd eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerCollectionSvc.add eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorRemove eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerCollectionSvc.remove eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorEstimatedValue eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id FROM player_collections WHERE id = ?" (Only eid) :: IO [PlayerCollection]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerCollectionSvc.estimated_value eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

