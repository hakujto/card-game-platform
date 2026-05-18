{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.OrderItemService
  ( validateOrderItem, line_total
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for OrderItem
validateOrderItem :: NewOrderItem -> Either String NewOrderItem
validateOrderItem body = Right body

-- @invoke behavior stub
line_total :: Int -> IO Text
line_total eid = do
  throwIO (userError "line_total not implemented")

