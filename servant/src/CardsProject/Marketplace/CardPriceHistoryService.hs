{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.CardPriceHistoryService where

import CardsProject.Marketplace.Types

-- Domain service stub for CardPriceHistory
validateCardPriceHistory :: NewCardPriceHistory -> Either String NewCardPriceHistory
validateCardPriceHistory body = Right body

