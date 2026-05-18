{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.CardPriceHistoryService
  ( validateCardPriceHistory, price_change_percent, is_price_spike
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for CardPriceHistory
validateCardPriceHistory :: NewCardPriceHistory -> Either String NewCardPriceHistory
validateCardPriceHistory body = Right body

-- @invoke behavior stub
price_change_percent :: Int -> IO Text
price_change_percent eid = do
  -- params: previous_avg: Decimal -- extract from body in handler when implementing
  throwIO (userError "price_change_percent not implemented")

-- @invoke behavior stub
is_price_spike :: Int -> IO Bool
is_price_spike eid = do
  -- params: threshold_percent: Int -- extract from body in handler when implementing
  throwIO (userError "is_price_spike not implemented")

