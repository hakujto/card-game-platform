{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckTagAssignmentService
  ( validateDeckTagAssignment
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)

-- Domain service stub for DeckTagAssignment
validateDeckTagAssignment :: NewDeckTagAssignment -> Either String NewDeckTagAssignment
validateDeckTagAssignment body = Right body

