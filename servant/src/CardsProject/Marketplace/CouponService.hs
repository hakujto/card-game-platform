{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.CouponService
  ( validateCoupon, is_valid, is_applicable_to_order, redeem, deactivate
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for Coupon
validateCoupon :: NewCoupon -> Either String NewCoupon
validateCoupon body = Right body

-- @invoke behavior stub (no-op)
is_valid :: Int -> IO Bool
is_valid _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
is_applicable_to_order :: Int -> IO Bool
is_applicable_to_order _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
redeem :: Int -> IO ()
redeem _eid = return ()

-- @invoke behavior stub (no-op)
deactivate :: Int -> IO ()
deactivate _eid = return ()

