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
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Marketplace.CouponService as CouponSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Text (Text)

type CouponAPI
  =    "api" :> "coupons" :> QueryParam "q" Text :> Get '[JSON] [Coupon]
  :<|> "api" :> "coupons" :> ReqBody '[JSON] NewCoupon :> PostCreated '[JSON] Coupon
  :<|> "api" :> "coupons" :> Capture "id" Int :> Get '[JSON] Coupon
  :<|> "api" :> "coupons" :> Capture "id" Int :> ReqBody '[JSON] NewCoupon :> Put '[JSON] Coupon
  :<|> "api" :> "coupons" :> Capture "id" Int :> ReqBody '[JSON] NewCoupon :> Patch '[JSON] Coupon
  :<|> "api" :> "coupons" :> Capture "id" Int :> "valid" :> Get '[JSON] Bool
  :<|> "api" :> "coupons" :> Capture "id" Int :> "applicable" :> Get '[JSON] Bool
  :<|> "api" :> "coupons" :> Capture "id" Int :> "redeem" :> PostNoContent
  :<|> "api" :> "coupons" :> Capture "id" Int :> "deactivate" :> PostNoContent

couponServer :: Server CouponAPI
couponServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> behaviorIsValid
  :<|> behaviorIsApplicableToOrder
  :<|> behaviorRedeem
  :<|> behaviorDeactivate
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons" :: IO [Coupon]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE code LIKE ?" (Only qp) :: IO [Coupon]

    create body = do
      case CouponSvc.validateCoupon body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO coupons (code, discount_type, discount_value, min_order_value, valid_from, valid_until, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)" validBody
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
      case CouponSvc.validateCoupon body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = [toField (bCouponCode validBody), toField (bCouponDiscountType validBody), toField (bCouponDiscountValue validBody), toField (bCouponMinOrderValue validBody), toField (bCouponValidFrom validBody), toField (bCouponValidUntil validBody), toField (bCouponIsActive validBody), toField eid]
            execute conn "UPDATE coupons SET code = ?, discount_type = ?, discount_value = ?, min_order_value = ?, valid_from = ?, valid_until = ?, is_active = ? WHERE id = ?" bodyRow
            query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    behaviorIsValid eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CouponSvc.is_valid eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorIsApplicableToOrder eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CouponSvc.is_applicable_to_order eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorRedeem eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CouponSvc.redeem eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDeactivate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active FROM coupons WHERE id = ?" (Only eid) :: IO [Coupon]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CouponSvc.deactivate eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

