{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.GameService
  ( validateGame, record_winner, duration_minutes
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for Game
validateGame :: NewGame -> Either String NewGame
validateGame body
  | not ((bGameGameNumber body >= 1 && bGameGameNumber body <= 3)) = Left "Game number must be between 1 and 3 (best-of-3)"
  | otherwise = validateGameImplies body

validateGameImplies :: NewGame -> Either String NewGame
validateGameImplies body
  | (bGameTurnsPlayed body /= Nothing) && not (maybe True (> 0) (bGameTurnsPlayed body)) = Left "Turns played must be greater than zero"
  | (bGameDurationSeconds body /= Nothing) && not (maybe True (> 0) (bGameDurationSeconds body)) = Left "Game duration must be greater than zero"
  | (bGameWinnerSide body == Just GameWinnerSideType_Draw) && not (bGameWinnerId body == Nothing) = Left "A draw cannot have a winner"
  | ((bGameWinnerSide body /= Nothing && bGameWinnerSide body /= Just GameWinnerSideType_Draw)) && not (bGameWinnerId body /= Nothing) = Left "A decisive game must have a winner player set"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
record_winner :: Int -> IO ()
record_winner _eid = throwIO (userError "record_winner not implemented")

-- @invoke behavior stub (no-op)
duration_minutes :: Int -> IO Text
duration_minutes _eid = throwIO (userError "duration_minutes not implemented")

