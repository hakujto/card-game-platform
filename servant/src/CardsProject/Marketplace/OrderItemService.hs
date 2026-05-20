{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.OrderItemService
  ( validateOrderItem, line_total
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for OrderItem
validateOrderItem :: NewOrderItem -> Either String NewOrderItem
validateOrderItem body = Right body

-- @invoke behavior stub (no-op)
line_total :: Int -> IO Text
line_total _eid = return (error "TODO")

