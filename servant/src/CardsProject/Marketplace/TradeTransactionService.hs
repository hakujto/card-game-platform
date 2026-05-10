{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeTransactionService where

import CardsProject.Marketplace.Types

-- Domain service stub for TradeTransaction
validateTradeTransaction :: NewTradeTransaction -> Either String NewTradeTransaction
validateTradeTransaction body = Right body

