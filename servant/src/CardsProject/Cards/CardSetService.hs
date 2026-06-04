{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardSetService
  ( validateCardSet, is_legal_in_standard, is_legal_in_format, card_count_by_rarity, rotate_out
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for CardSet
validateCardSet :: NewCardSet -> Either String NewCardSet
validateCardSet body
  | not (bCardSetTotalCards body > 0) = Left "Card set must have at least one card"
  | otherwise = validateCardSetImplies body

validateCardSetImplies :: NewCardSet -> Either String NewCardSet
validateCardSetImplies body
  | (bCardSetRotationDate body /= Nothing) && not (maybe True (> bCardSetReleaseDate body) (bCardSetRotationDate body)) = Left "Rotation date must be after release date"
  | (bCardSetIsRotated body == True) && not (bCardSetRotationDate body /= Nothing) = Left "Rotated set must have a rotation date"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
is_legal_in_standard :: Int -> IO Bool
is_legal_in_standard _eid = throwIO (userError "is_legal_in_standard not implemented")

-- @invoke behavior stub (no-op)
is_legal_in_format :: Int -> IO Bool
is_legal_in_format _eid = throwIO (userError "is_legal_in_format not implemented")

-- @invoke behavior stub (no-op)
card_count_by_rarity :: Int -> IO Int
card_count_by_rarity _eid = throwIO (userError "card_count_by_rarity not implemented")

-- @invoke behavior stub (no-op)
rotate_out :: Int -> IO ()
rotate_out _eid = throwIO (userError "rotate_out not implemented")

