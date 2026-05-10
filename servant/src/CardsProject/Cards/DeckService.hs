{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckService where

import CardsProject.Cards.Types

-- Domain service stub for Deck
validateDeck :: NewDeck -> Either String NewDeck
validateDeck body = Right body

