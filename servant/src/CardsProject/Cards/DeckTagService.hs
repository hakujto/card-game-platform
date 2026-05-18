{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckTagService
  ( validateDeckTag, merge_into, rename
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for DeckTag
validateDeckTag :: NewDeckTag -> Either String NewDeckTag
validateDeckTag body = Right body

-- @invoke behavior stub
merge_into :: Int -> IO ()
merge_into eid = do
  -- params: target_tag_id: Int -- extract from body in handler when implementing
  throwIO (userError "merge_into not implemented")

-- domain behavior stub
rename :: Text -> IO ()
rename _newName =
  throwIO (userError "rename not implemented")

