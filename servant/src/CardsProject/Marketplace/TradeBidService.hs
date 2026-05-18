{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeBidService
  ( validateTradeBid, outbid_by, retract
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for TradeBid
validateTradeBid :: NewTradeBid -> Either String NewTradeBid
validateTradeBid body = Right body

-- @invoke behavior stub
outbid_by :: Int -> IO Bool
outbid_by eid = do
  -- params: new_amount: Decimal -- extract from body in handler when implementing
  throwIO (userError "outbid_by not implemented")

-- @invoke behavior stub
retract :: Int -> IO ()
retract eid = do
  throwIO (userError "retract not implemented")

