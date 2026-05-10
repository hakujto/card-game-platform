{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.OrderService where

import CardsProject.Marketplace.Types

-- Domain service stub for Order
validateOrder :: NewOrder -> Either String NewOrder
validateOrder body = Right body

