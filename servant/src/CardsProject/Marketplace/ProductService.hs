{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.ProductService
  ( validateProduct, activate, deactivate, apply_discount, restock, effective_price, is_in_stock
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for Product
validateProduct :: NewProduct -> Either String NewProduct
validateProduct body
  | not (bProductPrice body > 0) = Left "Product price must be greater than zero"
  | not (bProductStock body >= 0) = Left "Product stock must not be negative"
  | not ((bProductDiscountPercent body >= 0 && bProductDiscountPercent body <= 100)) = Left "Product discount percent must be between 0 and 100"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
activate :: Int -> IO ()
activate _eid = throwIO (userError "activate not implemented")

-- @invoke behavior stub (no-op)
deactivate :: Int -> IO ()
deactivate _eid = throwIO (userError "deactivate not implemented")

-- @invoke behavior stub (no-op)
apply_discount :: Int -> IO Text
apply_discount _eid = throwIO (userError "apply_discount not implemented")

-- @invoke behavior stub (no-op)
restock :: Int -> IO ()
restock _eid = throwIO (userError "restock not implemented")

-- @invoke behavior stub (no-op)
effective_price :: Int -> IO Text
effective_price _eid = throwIO (userError "effective_price not implemented")

-- @invoke behavior stub (no-op)
is_in_stock :: Int -> IO Bool
is_in_stock _eid = throwIO (userError "is_in_stock not implemented")

