{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeListingService
  ( validateTradeListing, close, extend, cancel, is_expired, finalize_auction, setStatus, enumToText, assertTransition, allowedTransitions, transitionPendingToActive, transitionActiveToSold, transitionActiveToExpired, transitionActiveToCancelled, transitionSoldToActive, transitionExpiredToActive
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import qualified Data.Text
import Database.SQLite.Simple hiding (close)
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for TradeListing
validateTradeListing :: NewTradeListing -> Either String NewTradeListing
validateTradeListing body
  | not ((bTradeListingQuantity body >= 1 && bTradeListingQuantity body <= 9999)) = Left "Listing quantity must be between 1 and 9999"
  | otherwise = validateTradeListingImplies body

validateTradeListingImplies :: NewTradeListing -> Either String NewTradeListing
validateTradeListingImplies body
  | (bTradeListingListingType body == TradeListingListingTypeType_FixedPrice) && not (bTradeListingAskingPrice body /= Nothing) = Left "Fixed price listing must have an asking price"
  | (bTradeListingListingType body == TradeListingListingTypeType_Auction) && not (bTradeListingAuctionStartPrice body /= Nothing && bTradeListingAuctionEndTime body /= Nothing) = Left "Auction listing must have a start price and end time"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
close :: Int -> IO ()
close _eid = throwIO (userError "close not implemented")

-- @invoke behavior stub (no-op)
extend :: Int -> IO ()
extend _eid = throwIO (userError "extend not implemented")

-- @invoke behavior with @guard
cancel :: Int -> IO ()
cancel eid = withDb $ \conn -> do
  rows <- (query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing])
  case rows of
    [] -> throwIO (userError "TradeListing not found")
    (entity:_) -> do
      if not (tradeListingStatus entity == TradeListingStatusType_Active)
        then throwIO (userError "Guard condition not met for cancel")
        else throwIO (userError "cancel not implemented")

-- @invoke behavior stub (no-op)
is_expired :: Int -> IO Bool
is_expired _eid = throwIO (userError "is_expired not implemented")

-- @invoke behavior stub (no-op)
finalize_auction :: Int -> IO ()
finalize_auction _eid = throwIO (userError "finalize_auction not implemented")

-- triggered by @on(status = Sold)
setStatus :: Int -> Text -> IO ()
setStatus eid value = withDb $ \conn -> do
  execute conn "UPDATE trade_listings SET status = ? WHERE id = ?" (value, eid)
  if value == "Sold"
    then return () -- TODO: finalize_auction @on trigger
    else return ()

-- ── Lifecycle state machine ─────────────────────────────────────────
allowedTransitions :: [(Text, [Text])]
allowedTransitions =
  [   ("Pending", ["Active"])
  ,  ("Active", ["Sold", "Expired", "Cancelled"])
  ]

-- Convert status enum to Text: FooStatusType_Active -> "Active"
enumToText :: Show a => a -> Text
enumToText v = Data.Text.pack $ drop 1 $ dropWhile (/= '_') (show v)

assertTransition :: Text -> Text -> IO ()
assertTransition current to_ = do
  let allowed = maybe [] id (lookup current allowedTransitions)
  if to_ `elem` allowed
    then return ()
    else throwIO (userError $ "Transition " ++ show current ++ " -> " ++ show to_ ++ " not allowed")

transitionPendingToActive :: Int -> IO TradeListing
transitionPendingToActive eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
  case rows of
    [] -> throwIO (userError "TradeListing not found")
    (record:_) -> do
      assertTransition (enumToText (tradeListingStatus record)) "Active"
      execute conn "UPDATE trade_listings SET status = ? WHERE id = ?" ("Active" :: Text, eid)
      updated <- query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "TradeListing not found after update")

transitionActiveToSold :: Int -> IO TradeListing
transitionActiveToSold eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
  case rows of
    [] -> throwIO (userError "TradeListing not found")
    (record:_) -> do
      assertTransition (enumToText (tradeListingStatus record)) "Sold"
      execute conn "UPDATE trade_listings SET status = ? WHERE id = ?" ("Sold" :: Text, eid)
      finalize_auction eid  -- @after
      updated <- query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "TradeListing not found after update")

transitionActiveToExpired :: Int -> IO TradeListing
transitionActiveToExpired eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
  case rows of
    [] -> throwIO (userError "TradeListing not found")
    (record:_) -> do
      assertTransition (enumToText (tradeListingStatus record)) "Expired"
      execute conn "UPDATE trade_listings SET status = ? WHERE id = ?" ("Expired" :: Text, eid)
      close eid  -- @after
      updated <- query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "TradeListing not found after update")

transitionActiveToCancelled :: Int -> IO TradeListing
transitionActiveToCancelled eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
  case rows of
    [] -> throwIO (userError "TradeListing not found")
    (record:_) -> do
      assertTransition (enumToText (tradeListingStatus record)) "Cancelled"
      execute conn "UPDATE trade_listings SET status = ? WHERE id = ?" ("Cancelled" :: Text, eid)
      cancel eid  -- @after
      updated <- query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "TradeListing not found after update")

transitionSoldToActive :: Int -> IO TradeListing
transitionSoldToActive eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
  case rows of
    [] -> throwIO (userError "TradeListing not found")
    (record:_) -> do
      throwIO (userError "Transition Sold -> Active is not allowed")

transitionExpiredToActive :: Int -> IO TradeListing
transitionExpiredToActive eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
  case rows of
    [] -> throwIO (userError "TradeListing not found")
    (record:_) -> do
      throwIO (userError "Transition Expired -> Active is not allowed")

