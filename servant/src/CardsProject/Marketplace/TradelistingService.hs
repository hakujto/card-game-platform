{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeListingService
  ( validateTradeListing, close, extend, cancel, is_expired, finalize_auction, setStatus
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple hiding (close)
import CardsProject.Db (withDb)

-- Domain service stub for TradeListing
validateTradeListing :: NewTradeListing -> Either String NewTradeListing
validateTradeListing body = Right body

-- @invoke behavior stub
close :: Int -> IO ()
close eid = do
  throwIO (userError "close not implemented")

-- @invoke behavior stub
extend :: Int -> IO ()
extend eid = do
  -- params: days: Int -- extract from body in handler when implementing
  throwIO (userError "extend not implemented")

-- @invoke behavior stub
cancel :: Int -> IO ()
cancel eid = do
  throwIO (userError "cancel not implemented")

-- @invoke behavior stub
is_expired :: Int -> IO Bool
is_expired eid = do
  throwIO (userError "is_expired not implemented")

-- @invoke behavior stub
finalize_auction :: Int -> IO ()
finalize_auction eid = do
  throwIO (userError "finalize_auction not implemented")

-- triggered by @on(status = Sold)
setStatus :: Int -> Text -> IO ()
setStatus eid value = withDb $ \conn -> do
  execute conn "UPDATE trade_listings SET status = ? WHERE id = ?" (value, eid)
  if value == "SOLD"
    then throwIO (userError "finalize_auction not implemented") -- @on trigger stub
    else return ()

