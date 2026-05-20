{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftParticipantService
  ( validateDraftParticipant, pick_card, drafted_card_count
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for DraftParticipant
validateDraftParticipant :: NewDraftParticipant -> Either String NewDraftParticipant
validateDraftParticipant body = Right body

-- @invoke behavior stub (no-op)
pick_card :: Int -> IO ()
pick_card _eid = return ()

-- @invoke behavior stub (no-op)
drafted_card_count :: Int -> IO Int
drafted_card_count _eid = return (error "TODO")

