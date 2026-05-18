{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckSideboardCardService
  ( validateDeckSideboardCard, increment, decrement
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for DeckSideboardCard
validateDeckSideboardCard :: NewDeckSideboardCard -> Either String NewDeckSideboardCard
validateDeckSideboardCard body = Right body

-- domain behavior stub
increment :: Int -> IO ()
increment _amount =
  throwIO (userError "increment not implemented")

-- domain behavior stub
decrement :: Int -> IO ()
decrement _amount =
  throwIO (userError "decrement not implemented")

