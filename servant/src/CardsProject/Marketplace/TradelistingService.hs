{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradelistingService where

import CardsProject.Marketplace.Types

-- Domain service stub for Tradelisting
validateTradelisting :: NewTradelisting -> Either String NewTradelisting
validateTradelisting body = Right body

