{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.GameService
  ( validateGame, record_winner, duration_minutes
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Game
validateGame :: NewGame -> Either String NewGame
validateGame body = Right body

-- @invoke behavior stub
record_winner :: Int -> IO ()
record_winner eid = do
  -- params: winner_side: String -- extract from body in handler when implementing
  throwIO (userError "record_winner not implemented")

-- domain behavior stub
duration_minutes :: IO Text
duration_minutes  =
  throwIO (userError "duration_minutes not implemented")

