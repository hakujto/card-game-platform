{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.AwardedPrizeService
  ( validateAwardedPrize
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)

-- Domain service stub for AwardedPrize
validateAwardedPrize :: NewAwardedPrize -> Either String NewAwardedPrize
validateAwardedPrize body = Right body

