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

-- Domain service stub for TournamentPrize
validateTournamentPrize :: NewTournamentPrize -> Either String NewTournamentPrize
validateTournamentPrize body = Right body

-- @invoke behavior stub (no-op)
applies_to_placement :: Int -> IO Bool
applies_to_placement _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
award_to_player :: Int -> IO ()
award_to_player _eid = return ()

