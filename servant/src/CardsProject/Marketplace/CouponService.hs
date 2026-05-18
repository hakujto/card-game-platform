{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.CouponService
  ( validateCoupon, redeem, deactivate, is_valid, is_applicable_to_order
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
redeem :: Int -> IO ()
redeem eid = do
  throwIO (userError "redeem not implemented")

-- @invoke behavior stub
deactivate :: Int -> IO ()
deactivate eid = do
  throwIO (userError "deactivate not implemented")

-- domain behavior stub
is_valid :: IO Bool
is_valid  =
  throwIO (userError "is_valid not implemented")

-- domain behavior stub
is_applicable_to_order :: Text -> IO Bool
is_applicable_to_order _orderTotal =
  throwIO (userError "is_applicable_to_order not implemented")

