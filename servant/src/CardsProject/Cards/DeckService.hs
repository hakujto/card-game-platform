{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckService
  ( validateDeck, validate_size, add_card, remove_card, win_rate, clone, publish, unpublish, certify_tournament_legal
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for Deck
validateDeck :: NewDeck -> Either String NewDeck
validateDeck body
  | not (bDeckWins body >= 0) = Left "Deck wins count must not be negative"
  | not (bDeckLosses body >= 0) = Left "Deck losses count must not be negative"
  | not (bDeckDraws body >= 0) = Left "Deck draws count must not be negative"
  | otherwise = validateDeckImplies body

validateDeckImplies :: NewDeck -> Either String NewDeck
validateDeckImplies body
  | (bDeckIsTournamentLegal body == True) && not (bDeckIsPublic body == True) = Left "Tournament-legal deck must be made public"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
validate_size :: Int -> IO Bool
validate_size _eid = throwIO (userError "validate_size not implemented")

-- @invoke behavior stub (no-op)
add_card :: Int -> IO ()
add_card _eid = throwIO (userError "add_card not implemented")

-- @invoke behavior stub (no-op)
remove_card :: Int -> IO ()
remove_card _eid = throwIO (userError "remove_card not implemented")

-- @invoke behavior stub (no-op)
win_rate :: Int -> IO Text
win_rate _eid = throwIO (userError "win_rate not implemented")

-- @invoke behavior stub (no-op)
clone :: Int -> IO Text
clone _eid = throwIO (userError "clone not implemented")

-- @invoke behavior stub (no-op)
publish :: Int -> IO ()
publish _eid = throwIO (userError "publish not implemented")

-- @invoke behavior stub (no-op)
unpublish :: Int -> IO ()
unpublish _eid = throwIO (userError "unpublish not implemented")

-- @invoke behavior stub (no-op)
certify_tournament_legal :: Int -> IO Bool
certify_tournament_legal _eid = throwIO (userError "certify_tournament_legal not implemented")

-- ── Lifecycle hooks ─────────────────────────────────────────────────

-- TODO: implement recalculate_tournament_legal
recalculateTournamentLegalHook :: a -> IO ()
recalculateTournamentLegalHook _ = return ()

