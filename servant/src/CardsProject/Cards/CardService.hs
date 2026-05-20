{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardService
  ( validateCard, ban, unban, restrict, unrestrict, calculate_value, apply_rarity_bonus, is_legal_in_format
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for Card
validateCard :: NewCard -> Either String NewCard
validateCard body = Right body

-- @invoke behavior stub (no-op)
ban :: Int -> IO ()
ban _eid = return ()

-- @invoke behavior stub (no-op)
unban :: Int -> IO ()
unban _eid = return ()

-- @invoke behavior stub (no-op)
restrict :: Int -> IO ()
restrict _eid = return ()

-- @invoke behavior stub (no-op)
unrestrict :: Int -> IO ()
unrestrict _eid = return ()

-- @invoke behavior stub (no-op)
calculate_value :: Int -> IO Text
calculate_value _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
apply_rarity_bonus :: Int -> IO Text
apply_rarity_bonus _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
is_legal_in_format :: Int -> IO Bool
is_legal_in_format _eid = return (error "TODO")

