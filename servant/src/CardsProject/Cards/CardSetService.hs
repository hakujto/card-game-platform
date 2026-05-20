{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardSetService
  ( validateCardSet, is_legal_in_standard, is_legal_in_format, card_count_by_rarity, rotate_out
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for CardSet
validateCardSet :: NewCardSet -> Either String NewCardSet
validateCardSet body = Right body

-- @invoke behavior stub (no-op)
is_legal_in_standard :: Int -> IO Bool
is_legal_in_standard _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
is_legal_in_format :: Int -> IO Bool
is_legal_in_format _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
card_count_by_rarity :: Int -> IO Int
card_count_by_rarity _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
rotate_out :: Int -> IO ()
rotate_out _eid = return ()

