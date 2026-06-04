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

-- Domain service for DraftPick
validateDraftPick :: NewDraftPick -> Either String NewDraftPick
validateDraftPick body
  | not (bDraftPickPickNumber body > 0) = Left "Pick number must be greater than zero"
  | not ((bDraftPickPackNumber body >= 1 && bDraftPickPackNumber body <= 3)) = Left "Pack number must be between 1 and 3"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
is_first_pick :: Int -> IO Bool
is_first_pick _eid = throwIO (userError "is_first_pick not implemented")

