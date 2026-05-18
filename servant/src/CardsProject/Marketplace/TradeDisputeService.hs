{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeDisputeService
  ( validateTradeDispute, escalate, resolve, review
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for TradeDispute
validateTradeDispute :: NewTradeDispute -> Either String NewTradeDispute
validateTradeDispute body = Right body

-- @invoke behavior stub
escalate :: Int -> IO ()
escalate eid = do
  throwIO (userError "escalate not implemented")

-- @invoke behavior stub
resolve :: Int -> IO ()
resolve eid = do
  -- params: resolution_text: String -- extract from body in handler when implementing
  throwIO (userError "resolve not implemented")

-- @invoke behavior stub
review :: Int -> IO ()
review eid = do
  throwIO (userError "review not implemented")

