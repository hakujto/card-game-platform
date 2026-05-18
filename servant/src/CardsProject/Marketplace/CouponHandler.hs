{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.CouponHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Marketplace.CouponService as CouponSvc
import Data.Text (Text)

type CouponAPI
  =    "api" :> "coupons" :> Get '[JSON] [Coupon]
  :<|> "api" :> "coupons" :> ReqBody '[JSON] NewCoupon :> PostCreated '[JSON] Coupon
  :<|> "api" :> "coupons" :> Capture "id" Int :> Get '[JSON] Coupon
  :<|> "api" :> "coupons" :> Capture "id" Int :> ReqBody '[JSON] NewCoupon :> Put '[JSON] Coupon
  :<|> "api" :> "coupons" :> Capture "id" Int :> ReqBody '[JSON] NewCoupon :> Patch '[JSON] Coupon
  :<|> "api" :> "coupons" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "coupons" :> Capture "id" Int :> "valid" :> Get '[JSON] Bool
  :<|> "api" :> "coupons" :> Capture "id" Int :> "applicable" :> Get '[JSON] Bool
  :<|> "api" :> "coupons" :> Capture "id" Int :> "redeem" :> Post '[JSON] NoContent
  :<|> "api" :> "coupons" :> Capture "id" Int :> "deactivate" :> Post '[JSON] NoContent

couponServer :: Server CouponAPI
couponServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorIsValid
  :<|> behaviorIsApplicableToOrder
  :<|> behaviorRedeem
  :<|> behaviorDeactivate
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons" :: IO [Coupon]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO coupons (code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Coupon]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE coupons SET code = ?, discount_type = ?, discount_value = ?, min_order_value = ?, max_uses = ?, uses_count = ?, valid_from = ?, valid_until = ?, is_active = ? WHERE id = ?" bodyRow
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM coupons WHERE id = ?" (Only eid)
      return NoContent

    behaviorIsValid eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ CouponSvc.is_valid eid
          return result

    behaviorIsApplicableToOrder eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ CouponSvc.is_applicable_to_order eid
          return result

    behaviorRedeem eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ CouponSvc.redeem eid
          return NoContent

    behaviorDeactivate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ CouponSvc.deactivate eid
          return NoContent

