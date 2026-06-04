{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerCollectionService
  ( validatePlayerCollection, add, remove, estimated_value
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for PlayerCollection
validatePlayerCollection :: NewPlayerCollection -> Either String NewPlayerCollection
validatePlayerCollection body
  | not (bPlayerCollectionQuantity body > 0) = Left "Collection quantity must be greater than zero"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
add :: Int -> IO ()
add _eid = throwIO (userError "add not implemented")

-- @invoke behavior stub (no-op)
remove :: Int -> IO ()
remove _eid = throwIO (userError "remove not implemented")

-- @invoke behavior stub (no-op)
estimated_value :: Int -> IO Text
estimated_value _eid = throwIO (userError "estimated_value not implemented")

