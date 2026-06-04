{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.CouponService
  ( validateCoupon, is_valid, is_applicable_to_order, redeem, deactivate
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for Coupon
validateCoupon :: NewCoupon -> Either String NewCoupon
validateCoupon body
  | not (bCouponValidUntil body > bCouponValidFrom body) = Left "Coupon expiry must be after its start date"
  | not (bCouponDiscountValue body > 0) = Left "Discount value must be greater than zero"
  | otherwise = validateCouponImplies body

validateCouponImplies :: NewCoupon -> Either String NewCoupon
validateCouponImplies body
  | (bCouponDiscountType body == CouponDiscountTypeType_Percent) && not ((bCouponDiscountValue body >= 1 && bCouponDiscountValue body <= 100)) = Left "Percent discount must be between 1 and 100"
  | (bCouponMaxUses body /= Nothing) && not (bCouponUsesCount body <= (fromMaybe 0 (bCouponMaxUses body))) = Left "Coupon uses count cannot exceed max_uses"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
is_valid :: Int -> IO Bool
is_valid _eid = throwIO (userError "is_valid not implemented")

-- @invoke behavior stub (no-op)
is_applicable_to_order :: Int -> IO Bool
is_applicable_to_order _eid = throwIO (userError "is_applicable_to_order not implemented")

-- @invoke behavior stub (no-op)
redeem :: Int -> IO ()
redeem _eid = throwIO (userError "redeem not implemented")

-- @invoke behavior stub (no-op)
deactivate :: Int -> IO ()
deactivate _eid = throwIO (userError "deactivate not implemented")

