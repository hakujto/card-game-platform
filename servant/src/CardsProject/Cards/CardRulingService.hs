{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardRulingService
  ( validateCardRuling, is_current, supersedes_previous
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for CardRuling
validateCardRuling :: NewCardRuling -> Either String NewCardRuling
validateCardRuling body = Right body

-- @invoke behavior stub (no-op)
is_current :: Int -> IO Bool
is_current _eid = throwIO (userError "is_current not implemented")

-- @invoke behavior stub (no-op)
supersedes_previous :: Int -> IO Bool
supersedes_previous _eid = throwIO (userError "supersedes_previous not implemented")

