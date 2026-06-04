{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.TradeTransactionHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Marketplace.TradeTransactionService as TradeTransactionSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type TradeTransactionAPI
  =    "api" :> "trade_transactions" :> Get '[JSON] [TradeTransaction]
  :<|> "api" :> "trade_transactions" :> Capture "id" Int :> Get '[JSON] TradeTransaction
  :<|> "api" :> "trade_transactions" :> Capture "id" Int :> "complete" :> PostNoContent
  :<|> "api" :> "trade_transactions" :> Capture "id" Int :> "refund" :> PostNoContent
  :<|> "api" :> "trade_transactions" :> Capture "id" Int :> "dispute" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "trade_transactions" :> Capture "id" Int :> "seller-net" :> Get '[JSON] Text

tradeTransactionServer :: Server TradeTransactionAPI
tradeTransactionServer = listAll
  :<|> getOne
  :<|> behaviorComplete
  :<|> behaviorRefund
  :<|> behaviorOpenDispute
  :<|> behaviorSellerNet
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id FROM trade_transactions" :: IO [TradeTransaction]

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id FROM trade_transactions WHERE id = ?" (Only eid) :: IO [TradeTransaction]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorComplete eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id FROM trade_transactions WHERE id = ?" (Only eid) :: IO [TradeTransaction]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeTransactionSvc.complete eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorRefund eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id FROM trade_transactions WHERE id = ?" (Only eid) :: IO [TradeTransaction]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeTransactionSvc.refund eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorOpenDispute eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id FROM trade_transactions WHERE id = ?" (Only eid) :: IO [TradeTransaction]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeTransactionSvc.open_dispute eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorSellerNet eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id FROM trade_transactions WHERE id = ?" (Only eid) :: IO [TradeTransaction]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeTransactionSvc.seller_net eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

