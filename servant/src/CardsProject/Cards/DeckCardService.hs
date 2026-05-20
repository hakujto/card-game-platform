{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckCardService
  ( validateDeckCard, increment, decrement
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for DeckCard
validateDeckCard :: NewDeckCard -> Either String NewDeckCard
validateDeckCard body = Right body

-- @invoke behavior stub (no-op)
increment :: Int -> IO ()
increment _eid = return ()

-- @invoke behavior stub (no-op)
decrement :: Int -> IO ()
decrement _eid = return ()

