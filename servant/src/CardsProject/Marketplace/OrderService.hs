{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.OrderService
  ( validateOrder, cancel, pay, process_payment, calculate_total, apply_discount, refund, setStatus, notify_shipped, enumToText, assertTransition, allowedTransitions, transitionPendingToPaid, transitionPaidToProcessing, transitionProcessingToShipped, transitionShippedToCompleted, transitionPendingToCancelled, transitionPaidToCancelled, transitionCompletedToRefunded, transitionRefundedToCompleted, transitionCompletedToCancelled
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import qualified Data.Text
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for Order
validateOrder :: NewOrder -> Either String NewOrder
validateOrder body = Right body

-- @invoke behavior stub (no-op)
cancel :: Int -> IO ()
cancel _eid = return ()

-- @invoke behavior stub (no-op)
pay :: Int -> IO Bool
pay _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
process_payment :: Int -> IO Bool
process_payment _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
calculate_total :: Int -> IO Text
calculate_total _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
apply_discount :: Int -> IO Text
apply_discount _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
refund :: Int -> IO ()
refund _eid = return ()

-- @on behavior stub (no-op)
notify_shipped :: Int -> IO ()
notify_shipped _eid = return ()

-- triggered by @on(status = Shipped)
setStatus :: Int -> Text -> IO ()
setStatus eid value = withDb $ \conn -> do
  execute conn "UPDATE orders SET status = ? WHERE id = ?" (value, eid)
  if value == "SHIPPED"
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
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Paid"
      case orderPaymentMethod record of
        Nothing -> throwIO (userError "payment_method is required for Pending -> Paid")
        Just _  -> return ()
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Paid" :: Text, eid)
      process_payment eid  -- @after
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionPaidToProcessing :: Int -> IO Order
transitionPaidToProcessing eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Processing"
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Processing" :: Text, eid)
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionProcessingToShipped :: Int -> IO Order
transitionProcessingToShipped eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Shipped"
      case orderTrackingNumber record of
        Nothing -> throwIO (userError "tracking_number is required for Processing -> Shipped")
        Just _  -> return ()
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Shipped" :: Text, eid)
      notify_shipped eid  -- @after
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionShippedToCompleted :: Int -> IO Order
transitionShippedToCompleted eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Completed"
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Completed" :: Text, eid)
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionPendingToCancelled :: Int -> IO Order
transitionPendingToCancelled eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Cancelled"
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Cancelled" :: Text, eid)
      cancel eid  -- @after
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionPaidToCancelled :: Int -> IO Order
transitionPaidToCancelled eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Cancelled"
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Cancelled" :: Text, eid)
      cancel eid  -- @after
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionCompletedToRefunded :: Int -> IO Order
transitionCompletedToRefunded eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      assertTransition (enumToText (orderStatus record)) "Refunded"
      execute conn "UPDATE orders SET status = ? WHERE id = ?" ("Refunded" :: Text, eid)
      refund eid  -- @after
      updated <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Order not found after update")

transitionRefundedToCompleted :: Int -> IO Order
transitionRefundedToCompleted eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      throwIO (userError "Transition Refunded -> Completed is not allowed")

transitionCompletedToCancelled :: Int -> IO Order
transitionCompletedToCancelled eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, created_at, paid_at, shipped_at, player_id, items_id, coupon_id FROM orders WHERE id = ?" (Only eid) :: IO [Order]
  case rows of
    [] -> throwIO (userError "Order not found")
    (record:_) -> do
      throwIO (userError "Transition Completed -> Cancelled is not allowed")

