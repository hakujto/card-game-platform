{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentPrizeService
  ( validateTournamentPrize, applies_to_placement, award_to_player
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for TournamentPrize
validateTournamentPrize :: NewTournamentPrize -> Either String NewTournamentPrize
validateTournamentPrize body
  | bTournamentPrizePlacementFrom body < 1 = Left "placement_from: must be >= 1"
  | bTournamentPrizePlacementTo body < 1 = Left "placement_to: must be >= 1"
  | not (bTournamentPrizePlacementTo body >= bTournamentPrizePlacementFrom body) = Left "placement_to must be greater than or equal to placement_from"
  | not (bTournamentPrizePlacementFrom body > 0) = Left "placement_from must be greater than zero"
  | not (bTournamentPrizeAmount body >= 0) = Left "Prize amount must not be negative"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
applies_to_placement :: Int -> IO Bool
applies_to_placement _eid = throwIO (userError "applies_to_placement not implemented")

-- @invoke behavior stub (no-op)
award_to_player :: Int -> IO ()
award_to_player _eid = throwIO (userError "award_to_player not implemented")

