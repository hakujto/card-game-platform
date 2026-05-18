{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftSessionService
  ( validateDraftSession, start, abandon, complete, is_full
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for DraftSession
validateDraftSession :: NewDraftSession -> Either String NewDraftSession
validateDraftSession body = Right body

-- @invoke behavior stub
start :: Int -> IO ()
start eid = do
  throwIO (userError "start not implemented")

-- @invoke behavior stub
abandon :: Int -> IO ()
abandon eid = do
  throwIO (userError "abandon not implemented")

-- @invoke behavior stub
complete :: Int -> IO ()
complete eid = do
  throwIO (userError "complete not implemented")

-- @invoke behavior stub
is_full :: Int -> IO Bool
is_full eid = do
  throwIO (userError "is_full not implemented")

