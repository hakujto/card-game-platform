{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardSetService
  ( validateCardSet, is_legal_in_standard
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for CardSet
validateCardSet :: NewCardSet -> Either String NewCardSet
validateCardSet body = Right body

-- domain behavior stub
is_legal_in_standard :: IO Bool
is_legal_in_standard  =
  throwIO (userError "is_legal_in_standard not implemented")

