{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardService where

import CardsProject.Cards.Types

-- Domain service stub for Card
validateCard :: NewCard -> Either String NewCard
validateCard body = Right body

