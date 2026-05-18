{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckCardService
  ( validateDeckCard, increment, decrement
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for DeckCard
validateDeckCard :: NewDeckCard -> Either String NewDeckCard
validateDeckCard body = Right body

-- @invoke behavior stub
increment :: Int -> IO ()
increment eid = do
  -- params: amount: Int -- extract from body in handler when implementing
  throwIO (userError "increment not implemented")

-- @invoke behavior stub
decrement :: Int -> IO ()
decrement eid = do
  -- params: amount: Int -- extract from body in handler when implementing
  throwIO (userError "decrement not implemented")

