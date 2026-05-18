{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeBidService
  ( validateTradeBid, outbid_by
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for TradeBid
validateTradeBid :: NewTradeBid -> Either String NewTradeBid
validateTradeBid body = Right body

-- domain behavior stub
outbid_by :: Text -> IO Bool
outbid_by _newAmount =
  throwIO (userError "outbid_by not implemented")

