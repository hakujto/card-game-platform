{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeTransactionService
  ( validateTradeTransaction, complete, refund, open_dispute, seller_net
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for TradeTransaction
validateTradeTransaction :: NewTradeTransaction -> Either String NewTradeTransaction
validateTradeTransaction body = Right body

-- @invoke behavior stub (no-op)
complete :: Int -> IO ()
complete _eid = return ()

-- @invoke behavior stub (no-op)
refund :: Int -> IO ()
refund _eid = return ()

-- @invoke behavior stub (no-op)
open_dispute :: Int -> IO ()
open_dispute _eid = return ()

-- @invoke behavior stub (no-op)
seller_net :: Int -> IO Text
seller_net _eid = return (error "TODO")

