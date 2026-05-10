{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardAbilityService where

import CardsProject.Cards.Types

-- Domain service stub for CardAbility
validateCardAbility :: NewCardAbility -> Either String NewCardAbility
validateCardAbility body = Right body

