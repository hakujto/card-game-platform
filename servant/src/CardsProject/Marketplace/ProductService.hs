{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.ProductService
  ( validateProduct, activate, deactivate, apply_discount, restock, effective_price, is_in_stock
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Product
validateProduct :: NewProduct -> Either String NewProduct
validateProduct body = Right body

-- @invoke behavior stub
activate :: Int -> IO ()
activate eid = do
  throwIO (userError "activate not implemented")

-- @invoke behavior stub
deactivate :: Int -> IO ()
deactivate eid = do
  throwIO (userError "deactivate not implemented")

-- @invoke behavior stub
apply_discount :: Int -> IO Text
apply_discount eid = do
  -- params: percent: Int -- extract from body in handler when implementing
  throwIO (userError "apply_discount not implemented")

-- @invoke behavior stub
restock :: Int -> IO ()
restock eid = do
  -- params: quantity: Int -- extract from body in handler when implementing
  throwIO (userError "restock not implemented")

-- @invoke behavior stub
effective_price :: Int -> IO Text
effective_price eid = do
  throwIO (userError "effective_price not implemented")

-- @invoke behavior stub
is_in_stock :: Int -> IO Bool
is_in_stock eid = do
  throwIO (userError "is_in_stock not implemented")

