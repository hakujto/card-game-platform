{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckService
  ( validateDeck, validate_size, add_card, remove_card, win_rate, clone, publish, unpublish, certify_tournament_legal
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Deck
validateDeck :: NewDeck -> Either String NewDeck
validateDeck body = Right body

-- @invoke behavior stub
validate_size :: Int -> IO Bool
validate_size eid = do
  throwIO (userError "validate_size not implemented")

-- @invoke behavior stub
add_card :: Int -> IO ()
add_card eid = do
  -- params: card_id: Int, quantity: Int -- extract from body in handler when implementing
  throwIO (userError "add_card not implemented")

-- @invoke behavior stub
remove_card :: Int -> IO ()
remove_card eid = do
  -- params: card_id: Int -- extract from body in handler when implementing
  throwIO (userError "remove_card not implemented")

-- @invoke behavior stub
win_rate :: Int -> IO Text
win_rate eid = do
  throwIO (userError "win_rate not implemented")

-- @invoke behavior stub
clone :: Int -> IO Text
clone eid = do
  throwIO (userError "clone not implemented")

-- @invoke behavior stub
publish :: Int -> IO ()
publish eid = do
  throwIO (userError "publish not implemented")

-- @invoke behavior stub
unpublish :: Int -> IO ()
unpublish eid = do
  throwIO (userError "unpublish not implemented")

-- @invoke behavior stub
certify_tournament_legal :: Int -> IO Bool
certify_tournament_legal eid = do
  throwIO (userError "certify_tournament_legal not implemented")

