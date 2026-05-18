{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerCollectionService
  ( validatePlayerCollection, estimated_value, add, remove
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
estimated_value :: Int -> IO Text
estimated_value eid = do
  throwIO (userError "estimated_value not implemented")

-- domain behavior stub
add :: Int -> IO ()
add _quantity =
  throwIO (userError "add not implemented")

-- domain behavior stub
remove :: Int -> IO ()
remove _quantity =
  throwIO (userError "remove not implemented")

