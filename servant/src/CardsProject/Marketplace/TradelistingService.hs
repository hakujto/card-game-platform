{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradelistingService
  ( validateTradelisting, close, extend, cancel, is_expired, setStatus
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple hiding (close)
import CardsProject.Db (withDb)

-- Domain service stub for Tradelisting
validateTradelisting :: NewTradelisting -> Either String NewTradelisting
validateTradelisting body = Right body

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

-- domain behavior stub
is_expired :: IO Bool
is_expired  =
  throwIO (userError "is_expired not implemented")

-- triggered by @on(status = Sold)
setStatus :: Int -> Text -> IO ()
setStatus eid value = withDb $ \conn -> do
  execute conn "UPDATE tradelistings SET status = ? WHERE id = ?" (value, eid)
  if value == "SOLD"
    then throwIO (userError "finalize_auction not implemented") -- @on trigger stub
    else return ()

