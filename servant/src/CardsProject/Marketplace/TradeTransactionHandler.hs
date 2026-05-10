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

type TradeTransactionAPI
  =    "api" :> "trade_transactions" :> Get '[JSON] [TradeTransaction]
  :<|> "api" :> "trade_transactions" :> ReqBody '[JSON] NewTradeTransaction :> PostCreated '[JSON] TradeTransaction
  :<|> "api" :> "trade_transactions" :> Capture "id" Int :> Get '[JSON] TradeTransaction
  :<|> "api" :> "trade_transactions" :> Capture "id" Int :> ReqBody '[JSON] NewTradeTransaction :> Put '[JSON] TradeTransaction
  :<|> "api" :> "trade_transactions" :> Capture "id" Int :> ReqBody '[JSON] NewTradeTransaction :> Patch '[JSON] TradeTransaction
  :<|> "api" :> "trade_transactions" :> Capture "id" Int :> DeleteNoContent

tradeTransactionServer :: Server TradeTransactionAPI
tradeTransactionServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id FROM trade_transactions" :: IO [TradeTransaction]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO trade_transactions (final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id) VALUES (?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id FROM trade_transactions WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TradeTransaction]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id FROM trade_transactions WHERE id = ?" (Only eid) :: IO [TradeTransaction]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE trade_transactions SET final_price = ?, platform_fee = ?, status = ?, completed_at = ?, listing_id = ?, buyer_id = ?, seller_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id FROM trade_transactions WHERE id = ?" (Only eid) :: IO [TradeTransaction]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM trade_transactions WHERE id = ?" (Only eid)
      return NoContent

