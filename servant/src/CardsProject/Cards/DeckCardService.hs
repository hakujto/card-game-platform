{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckCardService
  ( validateDeckCard, increment, decrement
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for DeckCard
validateDeckCard :: NewDeckCard -> Either String NewDeckCard
validateDeckCard body
  | bDeckCardQuantity body < 1 = Left "quantity: must be >= 1"
  | bDeckCardQuantity body > 4 = Left "quantity: must be <= 4"
  | not ((bDeckCardQuantity body >= 1 && bDeckCardQuantity body <= 4)) = Left "A deck can contain between 1 and 4 copies of a card"
  | otherwise = validateDeckCardImplies body

validateDeckCardImplies :: NewDeckCard -> Either String NewDeckCard
validateDeckCardImplies body
  | (bDeckCardIsCommander body == True) && not (bDeckCardQuantity body == 1) = Left "Commander card must appear exactly once in the deck"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
increment :: Int -> IO ()
increment _eid = throwIO (userError "increment not implemented")

-- @invoke behavior stub (no-op)
decrement :: Int -> IO ()
decrement _eid = throwIO (userError "decrement not implemented")

