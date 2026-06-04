{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.OrderItemHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Marketplace.OrderItemService as OrderItemSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Text (Text)

type OrderItemAPI
  =    "api" :> "order_items" :> Get '[JSON] [OrderItem]
  :<|> "api" :> "order_items" :> ReqBody '[JSON] NewOrderItem :> PostCreated '[JSON] OrderItem
  :<|> "api" :> "order_items" :> Capture "id" Int :> Get '[JSON] OrderItem
  :<|> "api" :> "order_items" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "order_items" :> Capture "id" Int :> "total" :> Get '[JSON] Text

orderItemServer :: Server OrderItemAPI
orderItemServer = listAll
  :<|> create
  :<|> getOne
  :<|> delete
  :<|> behaviorLineTotal
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, quantity, price_at_purchase, foil, order_id, product_id FROM order_items" :: IO [OrderItem]

    create body = do
      case OrderItemSvc.validateOrderItem body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO order_items (quantity, price_at_purchase, foil, order_id, product_id) VALUES (?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, quantity, price_at_purchase, foil, order_id, product_id FROM order_items WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [OrderItem]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, price_at_purchase, foil, order_id, product_id FROM order_items WHERE id = ?" (Only eid) :: IO [OrderItem]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM order_items WHERE id = ?" (Only eid)
      return NoContent

    behaviorLineTotal eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, price_at_purchase, foil, order_id, product_id FROM order_items WHERE id = ?" (Only eid) :: IO [OrderItem]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> OrderItemSvc.line_total eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

