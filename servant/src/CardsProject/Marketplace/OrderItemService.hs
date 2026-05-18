{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.OrderItemService
  ( validateOrderItem, line_total
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for OrderItem
validateOrderItem :: NewOrderItem -> Either String NewOrderItem
validateOrderItem body = Right body

-- domain behavior stub
line_total :: IO Text
line_total  =
  throwIO (userError "line_total not implemented")

