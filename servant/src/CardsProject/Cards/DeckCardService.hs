{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckCardService
  ( validateDeckCard
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)

-- Domain service stub for DeckCard
validateDeckCard :: NewDeckCard -> Either String NewDeckCard
validateDeckCard body = Right body

