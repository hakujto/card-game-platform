{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.OrderHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type OrderAPI
  =    "api" :> "orders" :> Get '[JSON] [Order]
  :<|> "api" :> "orders" :> ReqBody '[JSON] NewOrder :> PostCreated '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> Get '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> ReqBody '[JSON] NewOrder :> Put '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> ReqBody '[JSON] NewOrder :> Patch '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> DeleteNoContent

orderServer :: Server OrderAPI
orderServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders" :: IO [Order]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO orders (status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Order]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE orders SET status = ?, total = ?, discount_applied = ?, currency = ?, payment_method = ?, payment_reference = ?, shipping_address = ?, tracking_number = ?, created_at = ?, paid_at = ?, shipped_at = ?, player_id = ?, items_id = ?, coupon_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM orders WHERE id = ?" (Only eid)
      return NoContent

