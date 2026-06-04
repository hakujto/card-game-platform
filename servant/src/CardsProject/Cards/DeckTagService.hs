{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckTagService
  ( validateDeckTag, rename, merge_into
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for DeckTag
validateDeckTag :: NewDeckTag -> Either String NewDeckTag
validateDeckTag body = Right body

-- @invoke behavior stub (no-op)
rename :: Int -> IO ()
rename _eid = throwIO (userError "rename not implemented")

-- @invoke behavior stub (no-op)
merge_into :: Int -> IO ()
merge_into _eid = throwIO (userError "merge_into not implemented")

