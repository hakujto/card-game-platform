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

-- Domain service stub for CardPriceHistory
validateCardPriceHistory :: NewCardPriceHistory -> Either String NewCardPriceHistory
validateCardPriceHistory body = Right body

-- @invoke behavior stub (no-op)
price_change_percent :: Int -> IO Text
price_change_percent _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
is_price_spike :: Int -> IO Bool
is_price_spike _eid = return (error "TODO")

