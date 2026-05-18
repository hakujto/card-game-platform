{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.CardPriceHistoryService
  ( validateCardPriceHistory, price_change_percent, is_price_spike
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for CardPriceHistory
validateCardPriceHistory :: NewCardPriceHistory -> Either String NewCardPriceHistory
validateCardPriceHistory body = Right body

-- domain behavior stub
price_change_percent :: Text -> IO Text
price_change_percent _previousAvg =
  throwIO (userError "price_change_percent not implemented")

-- domain behavior stub
is_price_spike :: Int -> IO Bool
is_price_spike _thresholdPercent =
  throwIO (userError "is_price_spike not implemented")

