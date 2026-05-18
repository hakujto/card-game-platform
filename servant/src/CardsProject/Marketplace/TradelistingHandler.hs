{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.TradeListingHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Marketplace.TradeListingService as TradeListingSvc
import Data.Aeson (Object)
import Data.Text (Text)

type TradeListingAPI
  =    "api" :> "trade_listings" :> Get '[JSON] [TradeListing]
  :<|> "api" :> "trade_listings" :> ReqBody '[JSON] NewTradeListing :> PostCreated '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> Get '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> ReqBody '[JSON] NewTradeListing :> Put '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> ReqBody '[JSON] NewTradeListing :> Patch '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "close" :> Post '[JSON] NoContent
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "extend" :> ReqBody '[JSON] Object :> Patch '[JSON] NoContent
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "cancel" :> DeleteNoContent
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "expired" :> Get '[JSON] Bool
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "finalize" :> Post '[JSON] NoContent

tradeListingServer :: Server TradeListingAPI
tradeListingServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorClose
  :<|> behaviorExtend
  :<|> behaviorCancel
  :<|> behaviorIsExpired
  :<|> behaviorFinalizeAuction
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM trade_listings" :: IO [TradeListing]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO trade_listings (listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM trade_listings WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TradeListing]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE trade_listings SET listing_type = ?, asking_price = ?, auction_start_price = ?, auction_current_bid = ?, auction_end_time = ?, foil = ?, condition = ?, quantity = ?, status = ?, description = ?, created_at = ?, expires_at = ?, seller_id = ?, card_id = ?, bids_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM trade_listings WHERE id = ?" (Only eid)
      return NoContent

    behaviorClose eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradeListingSvc.close eid
          return NoContent

    behaviorExtend eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradeListingSvc.extend eid
          return NoContent

    behaviorCancel eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradeListingSvc.cancel eid
          return NoContent

    behaviorIsExpired eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ TradeListingSvc.is_expired eid
          return result

    behaviorFinalizeAuction eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradeListingSvc.finalize_auction eid
          return NoContent

