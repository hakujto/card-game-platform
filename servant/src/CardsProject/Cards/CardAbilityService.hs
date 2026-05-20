{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardAbilityService
  ( validateCardAbility, is_usable_at, describe
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for CardAbility
validateCardAbility :: NewCardAbility -> Either String NewCardAbility
validateCardAbility body = Right body

-- @invoke behavior stub (no-op)
is_usable_at :: Int -> IO Bool
is_usable_at _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
describe :: Int -> IO Text
describe _eid = return (error "TODO")

