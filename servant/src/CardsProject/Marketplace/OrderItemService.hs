{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.OrderItemService where

import CardsProject.Marketplace.Types

-- Domain service stub for OrderItem
validateOrderItem :: NewOrderItem -> Either String NewOrderItem
validateOrderItem body = Right body

