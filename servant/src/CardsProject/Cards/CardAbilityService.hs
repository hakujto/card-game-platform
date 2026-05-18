{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardAbilityService
  ( validateCardAbility, is_usable_at, describe
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for CardAbility
validateCardAbility :: NewCardAbility -> Either String NewCardAbility
validateCardAbility body = Right body

-- domain behavior stub
is_usable_at :: Text -> IO Bool
is_usable_at _timing =
  throwIO (userError "is_usable_at not implemented")

-- domain behavior stub
describe :: IO Text
describe  =
  throwIO (userError "describe not implemented")

