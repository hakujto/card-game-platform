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

-- Domain service stub for PlayerCollection
validatePlayerCollection :: NewPlayerCollection -> Either String NewPlayerCollection
validatePlayerCollection body = Right body

-- @invoke behavior stub (no-op)
add :: Int -> IO ()
add _eid = return ()

-- @invoke behavior stub (no-op)
remove :: Int -> IO ()
remove _eid = return ()

-- @invoke behavior stub (no-op)
estimated_value :: Int -> IO Text
estimated_value _eid = return (error "TODO")

