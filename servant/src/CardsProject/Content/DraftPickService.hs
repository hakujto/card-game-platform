{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftPickService
  ( validateDraftPick, is_first_pick
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for DraftPick
validateDraftPick :: NewDraftPick -> Either String NewDraftPick
validateDraftPick body = Right body

-- @invoke behavior stub (no-op)
is_first_pick :: Int -> IO Bool
is_first_pick _eid = return (error "TODO")

