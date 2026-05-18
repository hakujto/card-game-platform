{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardRulingService
  ( validateCardRuling, is_current, supersedes_previous
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for CardRuling
validateCardRuling :: NewCardRuling -> Either String NewCardRuling
validateCardRuling body = Right body

-- domain behavior stub
is_current :: IO Bool
is_current  =
  throwIO (userError "is_current not implemented")

-- domain behavior stub
supersedes_previous :: IO Bool
supersedes_previous  =
  throwIO (userError "supersedes_previous not implemented")

