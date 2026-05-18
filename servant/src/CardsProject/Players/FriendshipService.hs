{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.FriendshipService
  ( validateFriendship, accept, decline, block
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Friendship
validateFriendship :: NewFriendship -> Either String NewFriendship
validateFriendship body = Right body

-- @invoke behavior stub
accept :: Int -> IO ()
accept eid = do
  throwIO (userError "accept not implemented")

-- @invoke behavior stub
decline :: Int -> IO ()
decline eid = do
  throwIO (userError "decline not implemented")

-- @invoke behavior stub
block :: Int -> IO ()
block eid = do
  throwIO (userError "block not implemented")

