{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.MatchService
  ( validateMatch, record_result, finalize_result, determine_winner, concede, draw, enumToText, assertTransition, allowedTransitions, transitionPendingToActive, transitionActiveToCompleted, transitionActiveToDraw, transitionPendingToBYE, transitionCompletedToActive, transitionDrawToActive, transitionBYEToActive
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import qualified Data.Text
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for Match
validateMatch :: NewMatch -> Either String NewMatch
validateMatch body
  | not ((bMatchPlayer1Wins body >= 0 && bMatchPlayer2Wins body >= 0)) = Left "Win counts must not be negative"
  | not (((bMatchPlayer1Wins body >= 0 && bMatchPlayer1Wins body <= 2) && (bMatchPlayer2Wins body >= 0 && bMatchPlayer2Wins body <= 2))) = Left "Win counts cannot exceed 2 in a best-of-3 match"
  | otherwise = validateMatchImplies body

validateMatchImplies :: NewMatch -> Either String NewMatch
validateMatchImplies body
  | (bMatchStatus body == MatchStatusType_BYE) && not (bMatchPlayer2Id body == Nothing) = Left "BYE match must not have a second player"
  | (bMatchEndedAt body /= Nothing) && not (maybe True (> (fromMaybe "" (bMatchStartedAt body))) (bMatchEndedAt body)) = Left "Match end time must be after start time"
  | (bMatchStatus body == MatchStatusType_Completed) && not (bMatchStartedAt body /= Nothing) = Left "Completed match must have a start time"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
record_result :: Int -> IO ()
record_result _eid = throwIO (userError "record_result not implemented")

-- @invoke behavior stub (no-op)
finalize_result :: Int -> IO ()
finalize_result _eid = throwIO (userError "finalize_result not implemented")

-- @invoke behavior stub (no-op)
determine_winner :: Int -> IO Bool
determine_winner _eid = throwIO (userError "determine_winner not implemented")

-- @invoke behavior with @guard
concede :: Int -> IO ()
concede eid = withDb $ \conn -> do
  rows <- (query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match])
  case rows of
    [] -> throwIO (userError "Match not found")
    (entity:_) -> do
      if not (matchStatus entity == MatchStatusType_Active)
        then throwIO (userError "Guard condition not met for concede")
        else throwIO (userError "concede not implemented")

-- @invoke behavior stub (no-op)
draw :: Int -> IO ()
draw _eid = throwIO (userError "draw not implemented")

-- ── Lifecycle state machine ─────────────────────────────────────────
allowedTransitions :: [(Text, [Text])]
allowedTransitions =
  [   ("Pending", ["Active", "BYE"])
  ,  ("Active", ["Completed", "Draw"])
  ]

-- Convert status enum to Text: FooStatusType_Active -> "Active"
enumToText :: Show a => a -> Text
enumToText v = Data.Text.pack $ drop 1 $ dropWhile (/= '_') (show v)

assertTransition :: Text -> Text -> IO ()
assertTransition current to_ = do
  let allowed = maybe [] id (lookup current allowedTransitions)
  if to_ `elem` allowed
    then return ()
    else throwIO (userError $ "Transition " ++ show current ++ " -> " ++ show to_ ++ " not allowed")

transitionPendingToActive :: Int -> IO Match
transitionPendingToActive eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
  case rows of
    [] -> throwIO (userError "Match not found")
    (record:_) -> do
      assertTransition (enumToText (matchStatus record)) "Active"
      execute conn "UPDATE matches SET status = ? WHERE id = ?" ("Active" :: Text, eid)
      updated <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Match not found after update")

transitionActiveToCompleted :: Int -> IO Match
transitionActiveToCompleted eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
  case rows of
    [] -> throwIO (userError "Match not found")
    (record:_) -> do
      assertTransition (enumToText (matchStatus record)) "Completed"
      execute conn "UPDATE matches SET status = ? WHERE id = ?" ("Completed" :: Text, eid)
      finalize_result eid  -- @after
      updated <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Match not found after update")

transitionActiveToDraw :: Int -> IO Match
transitionActiveToDraw eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
  case rows of
    [] -> throwIO (userError "Match not found")
    (record:_) -> do
      assertTransition (enumToText (matchStatus record)) "Draw"
      execute conn "UPDATE matches SET status = ? WHERE id = ?" ("Draw" :: Text, eid)
      draw eid  -- @after
      updated <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Match not found after update")

transitionPendingToBYE :: Int -> IO Match
transitionPendingToBYE eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
  case rows of
    [] -> throwIO (userError "Match not found")
    (record:_) -> do
      assertTransition (enumToText (matchStatus record)) "BYE"
      execute conn "UPDATE matches SET status = ? WHERE id = ?" ("BYE" :: Text, eid)
      updated <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Match not found after update")

transitionCompletedToActive :: Int -> IO Match
transitionCompletedToActive eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
  case rows of
    [] -> throwIO (userError "Match not found")
    (record:_) -> do
      throwIO (userError "Transition Completed -> Active is not allowed")

transitionDrawToActive :: Int -> IO Match
transitionDrawToActive eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
  case rows of
    [] -> throwIO (userError "Match not found")
    (record:_) -> do
      throwIO (userError "Transition Draw -> Active is not allowed")

transitionBYEToActive :: Int -> IO Match
transitionBYEToActive eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
  case rows of
    [] -> throwIO (userError "Match not found")
    (record:_) -> do
      throwIO (userError "Transition BYE -> Active is not allowed")

