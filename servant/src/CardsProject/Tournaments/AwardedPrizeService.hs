{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.AwardedPrizeService where

import CardsProject.Tournaments.Types

-- Domain service stub for AwardedPrize
validateAwardedPrize :: NewAwardedPrize -> Either String NewAwardedPrize
validateAwardedPrize body = Right body

