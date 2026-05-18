{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardService
  ( validateCard, ban, unban, restrict, unrestrict, calculate_value, apply_rarity_bonus, is_legal_in_format
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Card
validateCard :: NewCard -> Either String NewCard
validateCard body = Right body

-- @invoke behavior stub
ban :: Int -> IO ()
ban eid = do
  throwIO (userError "ban not implemented")

-- @invoke behavior stub
unban :: Int -> IO ()
unban eid = do
  throwIO (userError "unban not implemented")

-- @invoke behavior stub
restrict :: Int -> IO ()
restrict eid = do
  throwIO (userError "restrict not implemented")

-- @invoke behavior stub
unrestrict :: Int -> IO ()
unrestrict eid = do
  throwIO (userError "unrestrict not implemented")

-- @invoke behavior stub
calculate_value :: Int -> IO Text
calculate_value eid = do
  throwIO (userError "calculate_value not implemented")

-- @invoke behavior stub
apply_rarity_bonus :: Int -> IO Text
apply_rarity_bonus eid = do
  -- params: multiplier: Int -- extract from body in handler when implementing
  throwIO (userError "apply_rarity_bonus not implemented")

-- @invoke behavior stub
is_legal_in_format :: Int -> IO Bool
is_legal_in_format eid = do
  -- params: format: String -- extract from body in handler when implementing
  throwIO (userError "is_legal_in_format not implemented")

