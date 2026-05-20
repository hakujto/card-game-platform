{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentService
  ( validateTournament, start, cancel, complete, generate_round, calculate_prize_distribution, register_player, is_full, enumToText, assertTransition, allowedTransitions, transitionDraftToRegistration, transitionRegistrationToOngoing, transitionRegistrationToCancelled, transitionOngoingToCompleted, transitionOngoingToCancelled, transitionCompletedToDraft, transitionCancelledToDraft
  ) where

import CardsProject.Tournaments.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import qualified Data.Text
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for Tournament
validateTournament :: NewTournament -> Either String NewTournament
validateTournament body = Right body

-- @invoke behavior stub (no-op)
start :: Int -> IO ()
start _eid = return ()

-- @invoke behavior stub (no-op)
cancel :: Int -> IO ()
cancel _eid = return ()

-- @invoke behavior stub (no-op)
complete :: Int -> IO ()
complete _eid = return ()

-- @invoke behavior stub (no-op)
generate_round :: Int -> IO ()
generate_round _eid = return ()

-- @invoke behavior stub (no-op)
calculate_prize_distribution :: Int -> IO Text
calculate_prize_distribution _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
register_player :: Int -> IO ()
register_player _eid = return ()

-- @invoke behavior stub (no-op)
is_full :: Int -> IO Bool
is_full _eid = return (error "TODO")

-- ── Lifecycle state machine ─────────────────────────────────────────
allowedTransitions :: [(Text, [Text])]
allowedTransitions =
  [   ("Draft", ["Registration"])
  ,  ("Registration", ["Ongoing", "Cancelled"])
  ,  ("Ongoing", ["Completed", "Cancelled"])
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

transitionDraftToRegistration :: Int -> IO Tournament
transitionDraftToRegistration eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
  case rows of
    [] -> throwIO (userError "Tournament not found")
    (record:_) -> do
      assertTransition (enumToText (tournamentStatus record)) "Registration"
      execute conn "UPDATE tournaments SET status = ? WHERE id = ?" ("Registration" :: Text, eid)
      updated <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Tournament not found after update")

transitionRegistrationToOngoing :: Int -> IO Tournament
transitionRegistrationToOngoing eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
  case rows of
    [] -> throwIO (userError "Tournament not found")
    (record:_) -> do
      assertTransition (enumToText (tournamentStatus record)) "Ongoing"
      execute conn "UPDATE tournaments SET status = ? WHERE id = ?" ("Ongoing" :: Text, eid)
      start eid  -- @after
      updated <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Tournament not found after update")

transitionRegistrationToCancelled :: Int -> IO Tournament
transitionRegistrationToCancelled eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
  case rows of
    [] -> throwIO (userError "Tournament not found")
    (record:_) -> do
      assertTransition (enumToText (tournamentStatus record)) "Cancelled"
      execute conn "UPDATE tournaments SET status = ? WHERE id = ?" ("Cancelled" :: Text, eid)
      cancel eid  -- @after
      updated <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Tournament not found after update")

transitionOngoingToCompleted :: Int -> IO Tournament
transitionOngoingToCompleted eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
  case rows of
    [] -> throwIO (userError "Tournament not found")
    (record:_) -> do
      assertTransition (enumToText (tournamentStatus record)) "Completed"
      execute conn "UPDATE tournaments SET status = ? WHERE id = ?" ("Completed" :: Text, eid)
      complete eid  -- @after
      calculate_prize_distribution eid  -- @after
      updated <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Tournament not found after update")

transitionOngoingToCancelled :: Int -> IO Tournament
transitionOngoingToCancelled eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
  case rows of
    [] -> throwIO (userError "Tournament not found")
    (record:_) -> do
      assertTransition (enumToText (tournamentStatus record)) "Cancelled"
      execute conn "UPDATE tournaments SET status = ? WHERE id = ?" ("Cancelled" :: Text, eid)
      cancel eid  -- @after
      updated <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Tournament not found after update")

transitionCompletedToDraft :: Int -> IO Tournament
transitionCompletedToDraft eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
  case rows of
    [] -> throwIO (userError "Tournament not found")
    (record:_) -> do
      throwIO (userError "Transition Completed -> Draft is not allowed")

transitionCancelledToDraft :: Int -> IO Tournament
transitionCancelledToDraft eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, created_at, season_id, organizer_id, registrations_id, rounds_id, prizes_id FROM tournaments WHERE id = ?" (Only eid) :: IO [Tournament]
  case rows of
    [] -> throwIO (userError "Tournament not found")
    (record:_) -> do
      throwIO (userError "Transition Cancelled -> Draft is not allowed")

