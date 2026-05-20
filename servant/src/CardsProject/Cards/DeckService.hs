{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckService
  ( validateDeck, validate_size, add_card, remove_card, win_rate, clone, publish, unpublish, certify_tournament_legal
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for Deck
validateDeck :: NewDeck -> Either String NewDeck
validateDeck body = Right body

-- @invoke behavior stub (no-op)
validate_size :: Int -> IO Bool
validate_size _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
add_card :: Int -> IO ()
add_card _eid = return ()

-- @invoke behavior stub (no-op)
remove_card :: Int -> IO ()
remove_card _eid = return ()

-- @invoke behavior stub (no-op)
win_rate :: Int -> IO Text
win_rate _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
clone :: Int -> IO Text
clone _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
publish :: Int -> IO ()
publish _eid = return ()

-- @invoke behavior stub (no-op)
unpublish :: Int -> IO ()
unpublish _eid = return ()

-- @invoke behavior stub (no-op)
certify_tournament_legal :: Int -> IO Bool
certify_tournament_legal _eid = return (error "TODO")

