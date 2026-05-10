{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.CouponService where

import CardsProject.Marketplace.Types

-- Domain service stub for Coupon
validateCoupon :: NewCoupon -> Either String NewCoupon
validateCoupon body = Right body

