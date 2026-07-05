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
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Marketplace.OrderService as OrderSvc
import qualified Data.ByteString.Lazy.Char8
import Data.Text (Text)
import qualified Data.Text
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type OrderAPI
  =    "api" :> "orders" :> Get '[JSON] [Order]
  :<|> "api" :> "orders" :> ReqBody '[JSON] NewOrder :> PostCreated '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> Header "X-User-Id" Text :> Get '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> "cancel" :> DeleteNoContent
  :<|> "api" :> "orders" :> Capture "id" Int :> "pay" :> ReqBody '[JSON] Object :> Post '[JSON] Bool
  :<|> "api" :> "orders" :> Capture "id" Int :> "process-payment" :> Post '[JSON] Bool
  :<|> "api" :> "orders" :> Capture "id" Int :> "total" :> Get '[JSON] Text
  :<|> "api" :> "orders" :> Capture "id" Int :> "discount" :> ReqBody '[JSON] Object :> Patch '[JSON] Text
  :<|> "api" :> "orders" :> Capture "id" Int :> "refund" :> PostNoContent
  :<|> "api" :> "orders" :> Capture "id" Int :> "transitions" :> "pending-to-paid" :> Patch '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> "transitions" :> "paid-to-processing" :> Header "X-User-Role" Text :> Patch '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> "transitions" :> "processing-to-shipped" :> Header "X-User-Role" Text :> Patch '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> "transitions" :> "shipped-to-completed" :> Header "X-User-Role" Text :> Patch '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> "transitions" :> "pending-to-cancelled" :> Patch '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> "transitions" :> "paid-to-cancelled" :> Header "X-User-Role" Text :> Patch '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> "transitions" :> "completed-to-refunded" :> Header "X-User-Role" Text :> Patch '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> "transitions" :> "refunded-to-completed" :> Patch '[JSON] Order
  :<|> "api" :> "orders" :> Capture "id" Int :> "transitions" :> "completed-to-cancelled" :> Patch '[JSON] Order

orderServer :: Server OrderAPI
orderServer = listAll
  :<|> create
  :<|> getOne
  :<|> behaviorCancel
  :<|> behaviorPay
  :<|> behaviorProcessPayment
  :<|> behaviorCalculateTotal
  :<|> behaviorApplyDiscount
  :<|> behaviorRefund
  :<|> transitionHandlerPendingToPaid
  :<|> transitionHandlerPaidToProcessing
  :<|> transitionHandlerProcessingToShipped
  :<|> transitionHandlerShippedToCompleted
  :<|> transitionHandlerPendingToCancelled
  :<|> transitionHandlerPaidToCancelled
  :<|> transitionHandlerCompletedToRefunded
  :<|> transitionHandlerRefundedToCompleted
  :<|> transitionHandlerCompletedToCancelled
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders" :: IO [Order]

    create body = do
      case OrderSvc.validateOrder body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO orders (status, total, discount_applied, currency, payment_method, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Order]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid mUserId = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case rows of
        (r:_) -> case mUserId of
          Nothing  -> throwError err401
          Just uid -> if orderPlayerId r /= Just (read (Data.Text.unpack uid) :: Int)
            then throwError err403
            else return r
        []    -> throwError err404

    behaviorCancel eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> OrderSvc.cancel eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorPay eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> OrderSvc.pay eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorProcessPayment eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> OrderSvc.process_payment eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorCalculateTotal eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> OrderSvc.calculate_total eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorApplyDiscount eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> OrderSvc.apply_discount eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorRefund eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> OrderSvc.refund eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    transitionHandlerPendingToPaid eid = do
      result <- liftIO $ (OrderSvc.transitionPendingToPaid eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerPaidToProcessing eid mRole = do
      let allowedRoles = ["Admin", "Staff"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (OrderSvc.transitionPaidToProcessing eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerProcessingToShipped eid mRole = do
      let allowedRoles = ["Admin", "Staff"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (OrderSvc.transitionProcessingToShipped eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerShippedToCompleted eid mRole = do
      let allowedRoles = ["Admin", "Staff"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (OrderSvc.transitionShippedToCompleted eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerPendingToCancelled eid = do
      result <- liftIO $ (OrderSvc.transitionPendingToCancelled eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerPaidToCancelled eid mRole = do
      let allowedRoles = ["Admin", "Staff"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (OrderSvc.transitionPaidToCancelled eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerCompletedToRefunded eid mRole = do
      let allowedRoles = ["Admin"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (OrderSvc.transitionCompletedToRefunded eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerRefundedToCompleted eid = do
      result <- liftIO $ (OrderSvc.transitionRefundedToCompleted eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerCompletedToCancelled eid = do
      result <- liftIO $ (OrderSvc.transitionCompletedToCancelled eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

