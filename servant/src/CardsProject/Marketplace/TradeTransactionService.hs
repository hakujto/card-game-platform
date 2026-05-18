{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeTransactionService
  ( validateTradeTransaction, complete, refund, open_dispute, seller_net
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for TradeTransaction
validateTradeTransaction :: NewTradeTransaction -> Either String NewTradeTransaction
validateTradeTransaction body = Right body

-- @invoke behavior stub
complete :: Int -> IO ()
complete eid = do
  throwIO (userError "complete not implemented")

-- @invoke behavior stub
refund :: Int -> IO ()
refund eid = do
  throwIO (userError "refund not implemented")

-- @invoke behavior stub
open_dispute :: Int -> IO ()
open_dispute eid = do
  -- params: reason: String -- extract from body in handler when implementing
  throwIO (userError "open_dispute not implemented")

-- @invoke behavior stub
seller_net :: Int -> IO Text
seller_net eid = do
  throwIO (userError "seller_net not implemented")

