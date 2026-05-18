{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.MatchService
  ( validateMatch, record_result, determine_winner, draw
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Match
validateMatch :: NewMatch -> Either String NewMatch
validateMatch body = Right body

-- @invoke behavior stub
record_result :: Int -> IO ()
record_result eid = do
  -- params: p1_wins: Int, p2_wins: Int -- extract from body in handler when implementing
  -- @after(determine_winner): call determine_winner eid after this
  throwIO (userError "record_result not implemented")

-- @invoke behavior stub
determine_winner :: Int -> IO Bool
determine_winner eid = do
  throwIO (userError "determine_winner not implemented")

-- @invoke behavior stub
draw :: Int -> IO ()
draw eid = do
  throwIO (userError "draw not implemented")

