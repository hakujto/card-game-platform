{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.OrderService
  ( validateOrder, cancel, pay, process_payment, calculate_total, apply_discount, refund, setStatus, notify_shipped, enumToText, assertTransition, allowedTransitions, transitionPendingToPaid, transitionPaidToProcessing, transitionProcessingToShipped, transitionShippedToCompleted, transitionPendingToCancelled, transitionPaidToCancelled, transitionCompletedToRefunded, transitionRefundedToCompleted, transitionCompletedToCancelled
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import qualified Data.Text
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for Order
validateOrder :: NewOrder -> Either String NewOrder
validateOrder body
  | not (bOrderTotal body >= 0) = Left "Order total must not be negative"
  | not (bOrderDiscountApplied body <= bOrderTotal body) = Left "Discount applied cannot exceed order total"
  | (bOrderStatus body == OrderStatusType_Shipped) && (bOrderTrackingNumber body == Nothing) = Left "tracking_number is required"
  | (bOrderStatus body == OrderStatusType_Paid) && (bOrderPaidAt body == Nothing) = Left "paid_at is required"
  | otherwise = validateOrderImplies body

validateOrderImplies :: NewOrder -> Either String NewOrder
validateOrderImplies body
  | (bOrderStatus body == OrderStatusType_Paid) && not (bOrderPaidAt body /= Nothing) = Left "Paid order must have paid_at set"
  | (bOrderStatus body == OrderStatusType_Shipped) && not (bOrderTrackingNumber body /= Nothing) = Left "Shipped order must have a tracking number"
  | (bOrderShippedAt body /= Nothing) && not (bOrderStatus body == OrderStatusType_Shipped) = Left "shipped at requires shipped status"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
cancel :: Int -> IO ()
cancel _eid = throwIO (userError "cancel not implemented")

-- @invoke behavior with @guard
pay :: Int -> IO Bool
pay eid = withDb $ \conn -> do
  rows <- (query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order])
  case rows of
    [] -> throwIO (userError "Order not found")
    (entity:_) -> do
      if not (orderStatus entity == OrderStatusType_Pending)
        then throwIO (userError "Guard condition not met for pay")
        else throwIO (userError "pay not implemented")

-- @invoke behavior stub (no-op)
process_payment :: Int -> IO Bool
process_payment _eid = throwIO (userError "process_payment not implemented")

-- @invoke behavior stub (no-op)
calculate_total :: Int -> IO Text
calculate_total _eid = throwIO (userError "calculate_total not implemented")

-- @invoke behavior stub (no-op)
apply_discount :: Int -> IO Text
apply_discount _eid = throwIO (userError "apply_discount not implemented")

-- @invoke behavior stub (no-op)
refund :: Int -> IO ()
refund _eid = throwIO (userError "refund not implemented")

-- @on behavior stub (no-op)
notify_shipped :: Int -> IO ()
notify_shipped _eid = throwIO (userError "notify_shipped not implemented")

-- triggered by @on(status = Shipped)
setStatus :: Int -> Text -> IO ()
setStatus eid value = withDb $ \conn -> do
  execute conn "UPDATE orders SET status = ? WHERE id = ?" (value, eid)
  if value == "Shipped"
    then return () -- TODO: notify_shipped @on trigger
    else return ()

-- ── Lifecycle state machine ─────────────────────────────────────────
allowedTransitions :: [(Text, [Text])]
allowedTransitions =
  [   ("Pending", ["Paid", "Cancelled"])
  ,  ("Paid", ["Processing", "Cancelled"])
  ,  ("Processing", ["Shipped"])
  ,  ("Shipped", ["Completed"])
  ,  ("Completed", ["Refunded"])
  ]

-- Convert status enum to Text: FooStatusType_Active -> "Active"
enumToText :: Show a => a -> Text
enumToText v = Data.Text.pack $ drop 1 $ dropWhile (/= '_') (show v)

assertTransition :: Text -> Text -> IO ()
assertTransition current to_ = do
  let allowed = maybe [] id (lookup current allowedTransitions)
  if to_ `elem` allowed
    then return ()
    else throwIO (userError $ "Transition " ++ show current ++ " -> " ++ show to_ ++ " not allowed")

transitionPendingToPaid :: Int -> IO Order
transitionPendingToPaid eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Paid"
      case orderPaymentMethod record of
        Nothing -> throwIO (userError "payment_method is required for Pending -> Paid")
        Just _  -> return ()
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Paid" :: Text, eid)
      process_payment eid  -- @after
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionPaidToProcessing :: Int -> IO Order
transitionPaidToProcessing eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Processing"
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Processing" :: Text, eid)
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionProcessingToShipped :: Int -> IO Order
transitionProcessingToShipped eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Shipped"
      case orderTrackingNumber record of
        Nothing -> throwIO (userError "tracking_number is required for Processing -> Shipped")
        Just _  -> return ()
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Shipped" :: Text, eid)
      notify_shipped eid  -- @after
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionShippedToCompleted :: Int -> IO Order
transitionShippedToCompleted eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Completed"
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Completed" :: Text, eid)
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionPendingToCancelled :: Int -> IO Order
transitionPendingToCancelled eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Cancelled"
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Cancelled" :: Text, eid)
      cancel eid  -- @after
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionPaidToCancelled :: Int -> IO Order
transitionPaidToCancelled eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Cancelled"
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Cancelled" :: Text, eid)
      cancel eid  -- @after
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionCompletedToRefunded :: Int -> IO Order
transitionCompletedToRefunded eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Refunded"
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Refunded" :: Text, eid)
      refund eid  -- @after
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionRefundedToCompleted :: Int -> IO Order
transitionRefundedToCompleted eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      throwIO (userError "Transition Refunded -> Completed is not allowed")

transitionCompletedToCancelled :: Int -> IO Order
transitionCompletedToCancelled eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      throwIO (userError "Transition Completed -> Cancelled is not allowed")

-- ── Lifecycle hooks ─────────────────────────────────────────────────

-- TODO: implement assign_currency_default
assignCurrencyDefaultHook :: a -> IO ()
assignCurrencyDefaultHook _ = return ()

-- TODO: implement notify_status_change
notifyStatusChangeHook :: a -> IO ()
notifyStatusChangeHook _ = return ()

