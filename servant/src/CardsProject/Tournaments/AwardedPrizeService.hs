{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.AwardedPrizeService
  ( validateAwardedPrize, claim, setClaimed
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for AwardedPrize
validateAwardedPrize :: NewAwardedPrize -> Either String NewAwardedPrize
validateAwardedPrize body
  | not (bAwardedPrizeFinalPlacement body > 0) = Left "Final placement must be greater than zero"
  | otherwise = validateAwardedPrizeImplies body

validateAwardedPrizeImplies :: NewAwardedPrize -> Either String NewAwardedPrize
validateAwardedPrizeImplies body
  | (bAwardedPrizeClaimed body == True) && not (bAwardedPrizeClaimedAt body /= Nothing) = Left "Claimed prize must have a claimed_at timestamp"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
claim :: Int -> IO ()
claim _eid = throwIO (userError "claim not implemented")

-- triggered by @on(claimed = true)
setClaimed :: Int -> Text -> IO ()
setClaimed eid value = withDb $ \conn -> do
  execute conn "UPDATE awarded_prizes SET claimed = ? WHERE id = ?" (value, eid)
  if value == "true"
    then return () -- TODO: claim @on trigger
    else return ()

