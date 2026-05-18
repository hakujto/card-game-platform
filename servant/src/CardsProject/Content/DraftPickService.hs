{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftPickService
  ( validateDraftPick, is_first_pick
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for DraftPick
validateDraftPick :: NewDraftPick -> Either String NewDraftPick
validateDraftPick body = Right body

-- @invoke behavior stub
is_first_pick :: Int -> IO Bool
is_first_pick eid = do
  throwIO (userError "is_first_pick not implemented")

