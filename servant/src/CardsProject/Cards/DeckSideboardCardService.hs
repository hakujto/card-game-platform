{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckSideboardCardService
  ( validateDeckSideboardCard, increment, decrement
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for DeckSideboardCard
validateDeckSideboardCard :: NewDeckSideboardCard -> Either String NewDeckSideboardCard
validateDeckSideboardCard body
  | not ((bDeckSideboardCardQuantity body >= 1 && bDeckSideboardCardQuantity body <= 4)) = Left "Sideboard card quantity must be between 1 and 4 copies"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
increment :: Int -> IO ()
increment _eid = throwIO (userError "increment not implemented")

-- @invoke behavior stub (no-op)
decrement :: Int -> IO ()
decrement _eid = throwIO (userError "decrement not implemented")

