{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardRulingService
  ( validateCardRuling, is_current, supersedes_previous
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for CardRuling
validateCardRuling :: NewCardRuling -> Either String NewCardRuling
validateCardRuling body = Right body

-- @invoke behavior stub
is_current :: Int -> IO Bool
is_current eid = do
  throwIO (userError "is_current not implemented")

-- @invoke behavior stub
supersedes_previous :: Int -> IO Bool
supersedes_previous eid = do
  throwIO (userError "supersedes_previous not implemented")

