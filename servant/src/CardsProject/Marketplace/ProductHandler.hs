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
import Data.Aeson (Object)
import Data.Text (Text)

type ProductAPI
  =    "api" :> "products" :> Get '[JSON] [Product]
  :<|> "api" :> "products" :> ReqBody '[JSON] NewProduct :> PostCreated '[JSON] Product
  :<|> "api" :> "products" :> Capture "id" Int :> Get '[JSON] Product
  :<|> "api" :> "products" :> Capture "id" Int :> ReqBody '[JSON] NewProduct :> Put '[JSON] Product
  :<|> "api" :> "products" :> Capture "id" Int :> ReqBody '[JSON] NewProduct :> Patch '[JSON] Product
  :<|> "api" :> "products" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "products" :> Capture "id" Int :> "activate" :> Post '[JSON] NoContent
  :<|> "api" :> "products" :> Capture "id" Int :> "deactivate" :> Post '[JSON] NoContent
  :<|> "api" :> "products" :> Capture "id" Int :> "discount" :> ReqBody '[JSON] Object :> Patch '[JSON] Text
  :<|> "api" :> "products" :> Capture "id" Int :> "restock" :> ReqBody '[JSON] Object :> Post '[JSON] NoContent

productServer :: Server ProductAPI
productServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorActivate
  :<|> behaviorDeactivate
  :<|> behaviorApplyDiscount
  :<|> behaviorRestock
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products" :: IO [Product]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO products (name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
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
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE products SET name = ?, product_type = ?, price = ?, stock = ?, active = ?, discount_percent = ?, description = ?, image_url = ?, featured = ?, card_id = ?, card_set_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM products WHERE id = ?" (Only eid)
      return NoContent

    behaviorActivate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ ProductSvc.activate eid
          return NoContent

    behaviorDeactivate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ ProductSvc.deactivate eid
          return NoContent

    behaviorApplyDiscount eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ ProductSvc.apply_discount eid
          return result

    behaviorRestock eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id FROM products WHERE id = ?" (Only eid) :: IO [Product]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ ProductSvc.restock eid
          return NoContent

