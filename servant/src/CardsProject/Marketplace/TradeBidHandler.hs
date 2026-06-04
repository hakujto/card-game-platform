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
import qualified CardsProject.Marketplace.TradeBidService as TradeBidSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Text (Text)

type TradeBidAPI
  =    "api" :> "trade_bids" :> Get '[JSON] [TradeBid]
  :<|> "api" :> "trade_bids" :> ReqBody '[JSON] NewTradeBid :> PostCreated '[JSON] TradeBid
  :<|> "api" :> "trade_bids" :> Capture "id" Int :> Get '[JSON] TradeBid
  :<|> "api" :> "trade_bids" :> Capture "id" Int :> "outbid" :> Get '[JSON] Bool
  :<|> "api" :> "trade_bids" :> Capture "id" Int :> DeleteNoContent

tradeBidServer :: Server TradeBidAPI
tradeBidServer = listAll
  :<|> create
  :<|> getOne
  :<|> behaviorOutbidBy
  :<|> behaviorRetract
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, amount, placed_at, is_winning, listing_id, bidder_id FROM trade_bids" :: IO [TradeBid]

    create body = do
      case TradeBidSvc.validateTradeBid body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO trade_bids (amount, placed_at, is_winning, listing_id, bidder_id) VALUES (?, ?, ?, ?, ?)" validBody
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

    behaviorOutbidBy eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, amount, placed_at, is_winning, listing_id, bidder_id FROM trade_bids WHERE id = ?" (Only eid) :: IO [TradeBid]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeBidSvc.outbid_by eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorRetract eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, amount, placed_at, is_winning, listing_id, bidder_id FROM trade_bids WHERE id = ?" (Only eid) :: IO [TradeBid]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeBidSvc.retract eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

