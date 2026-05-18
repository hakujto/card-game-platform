{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerCollectionService
  ( validatePlayerCollection, add, remove, estimated_value
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for PlayerCollection
validatePlayerCollection :: NewPlayerCollection -> Either String NewPlayerCollection
validatePlayerCollection body = Right body

-- @invoke behavior stub
add :: Int -> IO ()
add eid = do
  -- params: quantity: Int -- extract from body in handler when implementing
  throwIO (userError "add not implemented")

-- @invoke behavior stub
remove :: Int -> IO ()
remove eid = do
  -- params: quantity: Int -- extract from body in handler when implementing
  throwIO (userError "remove not implemented")

-- @invoke behavior stub
estimated_value :: Int -> IO Text
estimated_value eid = do
  throwIO (userError "estimated_value not implemented")

