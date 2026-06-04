{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardAbilityService
  ( validateCardAbility, is_usable_at, describe
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for CardAbility
validateCardAbility :: NewCardAbility -> Either String NewCardAbility
validateCardAbility body = validateCardAbilityImplies body

validateCardAbilityImplies :: NewCardAbility -> Either String NewCardAbility
validateCardAbilityImplies body
  | (bCardAbilityAbilityType body == CardAbilityAbilityTypeType_Keyword) && not (bCardAbilityKeyword body /= Nothing) = Left "Keyword ability must have a keyword name"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
is_usable_at :: Int -> IO Bool
is_usable_at _eid = throwIO (userError "is_usable_at not implemented")

-- @invoke behavior stub (no-op)
describe :: Int -> IO Text
describe _eid = throwIO (userError "describe not implemented")

