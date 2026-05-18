{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.AwardedPrizeService
  ( validateAwardedPrize, claim, setClaimed
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for AwardedPrize
validateAwardedPrize :: NewAwardedPrize -> Either String NewAwardedPrize
validateAwardedPrize body = Right body

-- @invoke behavior stub
claim :: Int -> IO ()
claim eid = do
  throwIO (userError "claim not implemented")

-- triggered by @on(claimed = true)
setClaimed :: Int -> Text -> IO ()
setClaimed eid value = withDb $ \conn -> do
  execute conn "UPDATE awarded_prizes SET claimed = ? WHERE id = ?" (value, eid)
  if value == "TRUE"
    then throwIO (userError "claim not implemented") -- @on trigger stub
    else return ()

