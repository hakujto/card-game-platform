{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardSetService where

import CardsProject.Cards.Types

-- Domain service stub for CardSet
validateCardSet :: NewCardSet -> Either String NewCardSet
validateCardSet body = Right body

