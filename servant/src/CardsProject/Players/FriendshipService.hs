{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.FriendshipService
  ( validateFriendship, accept, decline, block
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for Friendship
validateFriendship :: NewFriendship -> Either String NewFriendship
validateFriendship body = Right body

-- @invoke behavior stub (no-op)
accept :: Int -> IO ()
accept _eid = return ()

-- @invoke behavior stub (no-op)
decline :: Int -> IO ()
decline _eid = return ()

-- @invoke behavior stub (no-op)
block :: Int -> IO ()
block _eid = return ()

