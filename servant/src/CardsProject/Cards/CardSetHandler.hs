{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.CardSetHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Cards.CardSetService as CardSetSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Text (Text)

type CardSetAPI
  =    "api" :> "card_sets" :> QueryParam "q" Text :> Get '[JSON] [CardSet]
  :<|> "api" :> "card_sets" :> ReqBody '[JSON] NewCardSet :> PostCreated '[JSON] CardSet
  :<|> "api" :> "card_sets" :> Capture "id" Int :> Get '[JSON] CardSet
  :<|> "api" :> "card_sets" :> Capture "id" Int :> ReqBody '[JSON] NewCardSet :> Put '[JSON] CardSet
  :<|> "api" :> "card_sets" :> Capture "id" Int :> ReqBody '[JSON] NewCardSet :> Patch '[JSON] CardSet
  :<|> "api" :> "card_sets" :> Capture "id" Int :> "standard-legal" :> Get '[JSON] Bool
  :<|> "api" :> "card_sets" :> Capture "id" Int :> "legal" :> Get '[JSON] Bool
  :<|> "api" :> "card_sets" :> Capture "id" Int :> "rarity-count" :> Get '[JSON] Int
  :<|> "api" :> "card_sets" :> Capture "id" Int :> "rotate" :> PostNoContent

cardSetServer :: Server CardSetAPI
cardSetServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> behaviorIsLegalInStandard
  :<|> behaviorIsLegalInFormat
  :<|> behaviorCardCountByRarity
  :<|> behaviorRotateOut
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url FROM card_sets" :: IO [CardSet]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url FROM card_sets WHERE name LIKE ? OR code LIKE ?" ((qp, qp)) :: IO [CardSet]

    create body = do
      case CardSetSvc.validateCardSet body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO card_sets (name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url FROM card_sets WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [CardSet]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url FROM card_sets WHERE id = ?" (Only eid) :: IO [CardSet]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      case CardSetSvc.validateCardSet body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = [toField (bCardSetName validBody), toField (bCardSetCode validBody), toField (bCardSetReleaseDate validBody), toField (bCardSetRotationDate validBody), toField (bCardSetSetType validBody), toField (bCardSetTotalCards validBody), toField (bCardSetIsRotated validBody), toField (bCardSetDescription validBody), toField (bCardSetLogoUrl validBody), toField eid]
            execute conn "UPDATE card_sets SET name = ?, code = ?, release_date = ?, rotation_date = ?, set_type = ?, total_cards = ?, is_rotated = ?, description = ?, logo_url = ? WHERE id = ?" bodyRow
            query conn "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url FROM card_sets WHERE id = ?" (Only eid) :: IO [CardSet]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    behaviorIsLegalInStandard eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url FROM card_sets WHERE id = ?" (Only eid) :: IO [CardSet]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSetSvc.is_legal_in_standard eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorIsLegalInFormat eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url FROM card_sets WHERE id = ?" (Only eid) :: IO [CardSet]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSetSvc.is_legal_in_format eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorCardCountByRarity eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url FROM card_sets WHERE id = ?" (Only eid) :: IO [CardSet]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSetSvc.card_count_by_rarity eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorRotateOut eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url FROM card_sets WHERE id = ?" (Only eid) :: IO [CardSet]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSetSvc.rotate_out eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

