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

-- Domain service stub for Product
validateProduct :: NewProduct -> Either String NewProduct
validateProduct body = Right body

-- @invoke behavior stub (no-op)
activate :: Int -> IO ()
activate _eid = return ()

-- @invoke behavior stub (no-op)
deactivate :: Int -> IO ()
deactivate _eid = return ()

-- @invoke behavior stub (no-op)
apply_discount :: Int -> IO Text
apply_discount _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
restock :: Int -> IO ()
restock _eid = return ()

-- @invoke behavior stub (no-op)
effective_price :: Int -> IO Text
effective_price _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
is_in_stock :: Int -> IO Bool
is_in_stock _eid = return (error "TODO")

