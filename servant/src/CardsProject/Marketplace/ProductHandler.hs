{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.ProductHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Marketplace.ProductService as ProductSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type ProductAPI
  =    "api" :> "products" :> QueryParam "q" Text :> Get '[JSON] [Product]
  :<|> "api" :> "products" :> ReqBody '[JSON] NewProduct :> PostCreated '[JSON] Product
  :<|> "api" :> "products" :> Capture "id" Int :> Get '[JSON] Product
  :<|> "api" :> "products" :> Capture "id" Int :> ReqBody '[JSON] NewProduct :> Put '[JSON] Product
  :<|> "api" :> "products" :> Capture "id" Int :> ReqBody '[JSON] NewProduct :> Patch '[JSON] Product
  :<|> "api" :> "products" :> Capture "id" Int :> "activate" :> PostNoContent
  :<|> "api" :> "products" :> Capture "id" Int :> "deactivate" :> PostNoContent
  :<|> "api" :> "products" :> Capture "id" Int :> "discount" :> ReqBody '[JSON] Object :> Patch '[JSON] Text
  :<|> "api" :> "products" :> Capture "id" Int :> "restock" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "products" :> Capture "id" Int :> "effective-price" :> Get '[JSON] Text
  :<|> "api" :> "products" :> Capture "id" Int :> "in-stock" :> Get '[JSON] Bool

productServer :: Server ProductAPI
productServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> behaviorActivate
  :<|> behaviorDeactivate
  :<|> behaviorApplyDiscount
  :<|> behaviorRestock
  :<|> behaviorEffectivePrice
  :<|> behaviorIsInStock
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products" :: IO [Product]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE name LIKE ? OR description LIKE ?" ((qp, qp)) :: IO [Product]

    create body = do
      case ProductSvc.validateProduct body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO products (name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Product]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      case ProductSvc.validateProduct body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = toRow validBody ++ toRow (Only eid)
            execute conn "UPDATE products SET name = ?, product_type = ?, price = ?, stock = ?, active = ?, discount_percent = ?, description = ?, image_url = ?, featured = ?, card_id = ?, card_set_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    behaviorActivate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ProductSvc.activate eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDeactivate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ProductSvc.deactivate eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorApplyDiscount eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ProductSvc.apply_discount eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorRestock eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ProductSvc.restock eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorEffectivePrice eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ProductSvc.effective_price eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorIsInStock eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ProductSvc.is_in_stock eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

