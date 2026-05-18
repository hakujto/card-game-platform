{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftParticipantService
  ( validateDraftParticipant, pick_card, drafted_card_count
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for DraftParticipant
validateDraftParticipant :: NewDraftParticipant -> Either String NewDraftParticipant
validateDraftParticipant body = Right body

-- @invoke behavior stub
pick_card :: Int -> IO ()
pick_card eid = do
  -- params: card_id: Int, pack_number: Int -- extract from body in handler when implementing
  throwIO (userError "pick_card not implemented")

-- domain behavior stub
drafted_card_count :: IO Int
drafted_card_count  =
  throwIO (userError "drafted_card_count not implemented")

