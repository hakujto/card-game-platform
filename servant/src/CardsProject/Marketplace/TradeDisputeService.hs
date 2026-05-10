{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeDisputeService where

import CardsProject.Marketplace.Types

-- Domain service stub for TradeDispute
validateTradeDispute :: NewTradeDispute -> Either String NewTradeDispute
validateTradeDispute body = Right body

