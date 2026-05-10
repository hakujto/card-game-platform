{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckTagService where

import CardsProject.Cards.Types

-- Domain service stub for DeckTag
validateDeckTag :: NewDeckTag -> Either String NewDeckTag
validateDeckTag body = Right body

