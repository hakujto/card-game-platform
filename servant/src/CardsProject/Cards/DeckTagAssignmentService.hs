{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckTagAssignmentService where

import CardsProject.Cards.Types

-- Domain service stub for DeckTagAssignment
validateDeckTagAssignment :: NewDeckTagAssignment -> Either String NewDeckTagAssignment
validateDeckTagAssignment body = Right body

