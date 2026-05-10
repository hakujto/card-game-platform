{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckCardService where

import CardsProject.Cards.Types

-- Domain service stub for DeckCard
validateDeckCard :: NewDeckCard -> Either String NewDeckCard
validateDeckCard body = Right body

