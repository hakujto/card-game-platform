{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.TradelistingHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Marketplace.TradelistingService as TradelistingSvc
import Data.Aeson (Object)
import Data.Text (Text)

type TradelistingAPI
  =    "api" :> "tradelistings" :> Get '[JSON] [Tradelisting]
  :<|> "api" :> "tradelistings" :> ReqBody '[JSON] NewTradelisting :> PostCreated '[JSON] Tradelisting
  :<|> "api" :> "tradelistings" :> Capture "id" Int :> Get '[JSON] Tradelisting
  :<|> "api" :> "tradelistings" :> Capture "id" Int :> ReqBody '[JSON] NewTradelisting :> Put '[JSON] Tradelisting
  :<|> "api" :> "tradelistings" :> Capture "id" Int :> ReqBody '[JSON] NewTradelisting :> Patch '[JSON] Tradelisting
  :<|> "api" :> "tradelistings" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "tradelistings" :> Capture "id" Int :> "close" :> Post '[JSON] NoContent
  :<|> "api" :> "tradelistings" :> Capture "id" Int :> "extend" :> ReqBody '[JSON] Object :> Patch '[JSON] NoContent
  :<|> "api" :> "tradelistings" :> Capture "id" Int :> "cancel" :> DeleteNoContent

tradelistingServer :: Server TradelistingAPI
tradelistingServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorClose
  :<|> behaviorExtend
  :<|> behaviorCancel
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM tradelistings" :: IO [Tradelisting]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO tradelistings (listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM tradelistings WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Tradelisting]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM tradelistings WHERE id = ?" (Only eid) :: IO [Tradelisting]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE tradelistings SET listing_type = ?, asking_price = ?, auction_start_price = ?, auction_current_bid = ?, auction_end_time = ?, foil = ?, condition = ?, quantity = ?, status = ?, description = ?, created_at = ?, expires_at = ?, seller_id = ?, card_id = ?, bids_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM tradelistings WHERE id = ?" (Only eid) :: IO [Tradelisting]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM tradelistings WHERE id = ?" (Only eid)
      return NoContent

    behaviorClose eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM tradelistings WHERE id = ?" (Only eid) :: IO [Tradelisting]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradelistingSvc.close eid
          return NoContent

    behaviorExtend eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM tradelistings WHERE id = ?" (Only eid) :: IO [Tradelisting]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradelistingSvc.extend eid
          return NoContent

    behaviorCancel eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, status, description, created_at, expires_at, seller_id, card_id, bids_id FROM tradelistings WHERE id = ?" (Only eid) :: IO [Tradelisting]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradelistingSvc.cancel eid
          return NoContent

