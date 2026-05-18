{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardAbilityService
  ( validateCardAbility, is_usable_at, describe
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for CardAbility
validateCardAbility :: NewCardAbility -> Either String NewCardAbility
validateCardAbility body = Right body

-- @invoke behavior stub
is_usable_at :: Int -> IO Bool
is_usable_at eid = do
  -- params: timing: String -- extract from body in handler when implementing
  throwIO (userError "is_usable_at not implemented")

-- @invoke behavior stub
describe :: Int -> IO Text
describe eid = do
  throwIO (userError "describe not implemented")

