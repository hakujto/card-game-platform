{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeTransactionService
  ( validateTradeTransaction, complete, refund, open_dispute, seller_net
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for TradeTransaction
validateTradeTransaction :: NewTradeTransaction -> Either String NewTradeTransaction
validateTradeTransaction body
  | not (bTradeTransactionPlatformFee body <= bTradeTransactionFinalPrice body) = Left "Platform fee cannot exceed the final price"
  | not (bTradeTransactionPlatformFee body >= 0) = Left "Platform fee must not be negative"
  | not (bTradeTransactionFinalPrice body > 0) = Left "Transaction final price must be greater than zero"
  | (bTradeTransactionStatus body == TradeTransactionStatusType_Completed) && (bTradeTransactionCompletedAt body == Nothing) = Left "completed_at is required"
  | otherwise = validateTradeTransactionImplies body

validateTradeTransactionImplies :: NewTradeTransaction -> Either String NewTradeTransaction
validateTradeTransactionImplies body
  | (bTradeTransactionStatus body == TradeTransactionStatusType_Completed) && not (bTradeTransactionCompletedAt body /= Nothing) = Left "Completed transaction must have a completed_at timestamp"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
complete :: Int -> IO ()
complete _eid = throwIO (userError "complete not implemented")

-- @invoke behavior stub (no-op)
refund :: Int -> IO ()
refund _eid = throwIO (userError "refund not implemented")

-- @invoke behavior stub (no-op)
open_dispute :: Int -> IO ()
open_dispute _eid = throwIO (userError "open_dispute not implemented")

-- @invoke behavior stub (no-op)
seller_net :: Int -> IO Text
seller_net _eid = throwIO (userError "seller_net not implemented")

