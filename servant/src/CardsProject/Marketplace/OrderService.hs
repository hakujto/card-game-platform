{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.OrderService
  ( validateOrder, cancel, pay, calculate_total, apply_discount, refund, setStatus
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Order
validateOrder :: NewOrder -> Either String NewOrder
validateOrder body = Right body

-- @invoke behavior stub
cancel :: Int -> IO ()
cancel eid = do
  throwIO (userError "cancel not implemented")

-- @invoke behavior stub
pay :: Int -> IO Bool
pay eid = do
  -- params: payment_ref: String -- extract from body in handler when implementing
  throwIO (userError "pay not implemented")

-- @invoke behavior stub
calculate_total :: Int -> IO Text
calculate_total eid = do
  throwIO (userError "calculate_total not implemented")

-- @invoke behavior stub
apply_discount :: Int -> IO Text
apply_discount eid = do
  -- params: percent: Int -- extract from body in handler when implementing
  throwIO (userError "apply_discount not implemented")

-- @invoke behavior stub
refund :: Int -> IO ()
refund eid = do
  throwIO (userError "refund not implemented")

-- triggered by @on(status = Shipped)
setStatus :: Int -> Text -> IO ()
setStatus eid value = withDb $ \conn -> do
  execute conn "UPDATE orders SET status = ? WHERE id = ?" (value, eid)
  if value == "SHIPPED"
    then throwIO (userError "notify_shipped not implemented") -- @on trigger stub
    else return ()

