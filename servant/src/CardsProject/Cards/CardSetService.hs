{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardSetService
  ( validateCardSet, is_legal_in_standard, is_legal_in_format, card_count_by_rarity, rotate_out
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for CardSet
validateCardSet :: NewCardSet -> Either String NewCardSet
validateCardSet body = Right body

-- @invoke behavior stub
is_legal_in_standard :: Int -> IO Bool
is_legal_in_standard eid = do
  throwIO (userError "is_legal_in_standard not implemented")

-- @invoke behavior stub
is_legal_in_format :: Int -> IO Bool
is_legal_in_format eid = do
  -- params: format: String -- extract from body in handler when implementing
  throwIO (userError "is_legal_in_format not implemented")

-- @invoke behavior stub
card_count_by_rarity :: Int -> IO Int
card_count_by_rarity eid = do
  -- params: rarity: String -- extract from body in handler when implementing
  throwIO (userError "card_count_by_rarity not implemented")

-- @invoke behavior stub
rotate_out :: Int -> IO ()
rotate_out eid = do
  throwIO (userError "rotate_out not implemented")

