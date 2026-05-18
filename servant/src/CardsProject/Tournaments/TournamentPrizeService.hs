{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentPrizeService
  ( validateTournamentPrize, applies_to_placement
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for TournamentPrize
validateTournamentPrize :: NewTournamentPrize -> Either String NewTournamentPrize
validateTournamentPrize body = Right body

-- domain behavior stub
applies_to_placement :: Int -> IO Bool
applies_to_placement _placement =
  throwIO (userError "applies_to_placement not implemented")

