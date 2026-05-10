{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardRulingService where

import CardsProject.Cards.Types

-- Domain service stub for CardRuling
validateCardRuling :: NewCardRuling -> Either String NewCardRuling
validateCardRuling body = Right body

