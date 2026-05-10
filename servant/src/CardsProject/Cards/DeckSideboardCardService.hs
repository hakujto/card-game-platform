{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckSideboardCardService where

import CardsProject.Cards.Types

-- Domain service stub for DeckSideboardCard
validateDeckSideboardCard :: NewDeckSideboardCard -> Either String NewDeckSideboardCard
validateDeckSideboardCard body = Right body

