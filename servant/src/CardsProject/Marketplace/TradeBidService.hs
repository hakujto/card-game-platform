{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeBidService where

import CardsProject.Marketplace.Types

-- Domain service stub for TradeBid
validateTradeBid :: NewTradeBid -> Either String NewTradeBid
validateTradeBid body = Right body

