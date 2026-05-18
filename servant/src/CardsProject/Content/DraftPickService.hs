{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftPickService
  ( validateDraftPick, is_first_pick
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for DraftPick
validateDraftPick :: NewDraftPick -> Either String NewDraftPick
validateDraftPick body = Right body

-- domain behavior stub
is_first_pick :: IO Bool
is_first_pick  =
  throwIO (userError "is_first_pick not implemented")

