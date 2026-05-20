{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeBidService
  ( validateTradeBid, outbid_by, retract
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for TradeBid
validateTradeBid :: NewTradeBid -> Either String NewTradeBid
validateTradeBid body = Right body

-- @invoke behavior stub (no-op)
outbid_by :: Int -> IO Bool
outbid_by _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
retract :: Int -> IO ()
retract _eid = return ()

