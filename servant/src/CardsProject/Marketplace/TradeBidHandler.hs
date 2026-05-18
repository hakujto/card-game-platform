{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.TradeBidHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type TradeBidAPI
  =    "api" :> "trade_bids" :> Get '[JSON] [TradeBid]
  :<|> "api" :> "trade_bids" :> ReqBody '[JSON] NewTradeBid :> PostCreated '[JSON] TradeBid
  :<|> "api" :> "trade_bids" :> Capture "id" Int :> Get '[JSON] TradeBid
  :<|> "api" :> "trade_bids" :> Capture "id" Int :> ReqBody '[JSON] NewTradeBid :> Put '[JSON] TradeBid
  :<|> "api" :> "trade_bids" :> Capture "id" Int :> ReqBody '[JSON] NewTradeBid :> Patch '[JSON] TradeBid
  :<|> "api" :> "trade_bids" :> Capture "id" Int :> DeleteNoContent

tradeBidServer :: Server TradeBidAPI
tradeBidServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, amount, placed_at, is_winning, listing_id, bidder_id FROM trade_bids" :: IO [TradeBid]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO trade_bids (amount, placed_at, is_winning, listing_id, bidder_id) VALUES (?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, amount, placed_at, is_winning, listing_id, bidder_id FROM trade_bids WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TradeBid]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, amount, placed_at, is_winning, listing_id, bidder_id FROM trade_bids WHERE id = ?" (Only eid) :: IO [TradeBid]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE trade_bids SET amount = ?, placed_at = ?, is_winning = ?, listing_id = ?, bidder_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, amount, placed_at, is_winning, listing_id, bidder_id FROM trade_bids WHERE id = ?" (Only eid) :: IO [TradeBid]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM trade_bids WHERE id = ?" (Only eid)
      return NoContent

