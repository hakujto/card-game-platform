{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentPrizeService
  ( validateTournamentPrize, applies_to_placement, award_to_player
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for TournamentPrize
validateTournamentPrize :: NewTournamentPrize -> Either String NewTournamentPrize
validateTournamentPrize body = Right body

-- @invoke behavior stub
applies_to_placement :: Int -> IO Bool
applies_to_placement eid = do
  -- params: placement: Int -- extract from body in handler when implementing
  throwIO (userError "applies_to_placement not implemented")

-- @invoke behavior stub
award_to_player :: Int -> IO ()
award_to_player eid = do
  -- params: player_id: Int -- extract from body in handler when implementing
  throwIO (userError "award_to_player not implemented")

