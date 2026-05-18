{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.CouponService
  ( validateCoupon, is_valid, is_applicable_to_order, redeem, deactivate
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Coupon
validateCoupon :: NewCoupon -> Either String NewCoupon
validateCoupon body = Right body

-- @invoke behavior stub
is_valid :: Int -> IO Bool
is_valid eid = do
  throwIO (userError "is_valid not implemented")

-- @invoke behavior stub
is_applicable_to_order :: Int -> IO Bool
is_applicable_to_order eid = do
  -- params: order_total: Decimal -- extract from body in handler when implementing
  throwIO (userError "is_applicable_to_order not implemented")

-- @invoke behavior stub
redeem :: Int -> IO ()
redeem eid = do
  throwIO (userError "redeem not implemented")

-- @invoke behavior stub
deactivate :: Int -> IO ()
deactivate eid = do
  throwIO (userError "deactivate not implemented")

