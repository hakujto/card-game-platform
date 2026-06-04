{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.CardPriceHistoryService
  ( validateCardPriceHistory, price_change_percent, is_price_spike
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for CardPriceHistory
validateCardPriceHistory :: NewCardPriceHistory -> Either String NewCardPriceHistory
validateCardPriceHistory body
  | not ((bCardPriceHistoryMinPrice body <= bCardPriceHistoryAvgPrice body && bCardPriceHistoryAvgPrice body <= bCardPriceHistoryMaxPrice body)) = Left "min_price <= avg_price <= max_price must hold"
  | not (bCardPriceHistoryVolume body >= 0) = Left "Price history volume must not be negative"
  | not (bCardPriceHistoryMinPrice body >= 0) = Left "Prices must not be negative"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
price_change_percent :: Int -> IO Text
price_change_percent _eid = throwIO (userError "price_change_percent not implemented")

-- @invoke behavior stub (no-op)
is_price_spike :: Int -> IO Bool
is_price_spike _eid = throwIO (userError "is_price_spike not implemented")

