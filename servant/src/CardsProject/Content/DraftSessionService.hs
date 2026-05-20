{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftSessionService
  ( validateDraftSession, start, abandon, complete, is_full, enumToText, assertTransition, allowedTransitions, transitionWaitingForPlayersToDrafting, transitionDraftingToCompleted, transitionDraftingToAbandoned, transitionWaitingForPlayersToAbandoned, transitionCompletedToDrafting, transitionAbandonedToDrafting
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import qualified Data.Text
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for DraftSession
validateDraftSession :: NewDraftSession -> Either String NewDraftSession
validateDraftSession body = Right body

-- @invoke behavior stub (no-op)
start :: Int -> IO ()
start _eid = return ()

-- @invoke behavior stub (no-op)
abandon :: Int -> IO ()
abandon _eid = return ()

-- @invoke behavior stub (no-op)
complete :: Int -> IO ()
complete _eid = return ()

-- @invoke behavior stub (no-op)
is_full :: Int -> IO Bool
is_full _eid = return (error "TODO")

-- ── Lifecycle state machine ─────────────────────────────────────────
allowedTransitions :: [(Text, [Text])]
allowedTransitions =
  [   ("WaitingForPlayers", ["Drafting", "Abandoned"])
  ,  ("Drafting", ["Completed", "Abandoned"])
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

transitionWaitingForPlayersToDrafting :: Int -> IO DraftSession
transitionWaitingForPlayersToDrafting eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
  case rows of
    [] -> throwIO (userError "DraftSession not found")
    (record:_) -> do
      assertTransition (enumToText (draftSessionStatus record)) "Drafting"
      execute conn "UPDATE draft_sessions SET status = ? WHERE id = ?" ("Drafting" :: Text, eid)
      start eid  -- @after
      updated <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "DraftSession not found after update")

transitionDraftingToCompleted :: Int -> IO DraftSession
transitionDraftingToCompleted eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
  case rows of
    [] -> throwIO (userError "DraftSession not found")
    (record:_) -> do
      assertTransition (enumToText (draftSessionStatus record)) "Completed"
      execute conn "UPDATE draft_sessions SET status = ? WHERE id = ?" ("Completed" :: Text, eid)
      complete eid  -- @after
      updated <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "DraftSession not found after update")

transitionDraftingToAbandoned :: Int -> IO DraftSession
transitionDraftingToAbandoned eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
  case rows of
    [] -> throwIO (userError "DraftSession not found")
    (record:_) -> do
      assertTransition (enumToText (draftSessionStatus record)) "Abandoned"
      execute conn "UPDATE draft_sessions SET status = ? WHERE id = ?" ("Abandoned" :: Text, eid)
      abandon eid  -- @after
      updated <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "DraftSession not found after update")

transitionWaitingForPlayersToAbandoned :: Int -> IO DraftSession
transitionWaitingForPlayersToAbandoned eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
  case rows of
    [] -> throwIO (userError "DraftSession not found")
    (record:_) -> do
      assertTransition (enumToText (draftSessionStatus record)) "Abandoned"
      execute conn "UPDATE draft_sessions SET status = ? WHERE id = ?" ("Abandoned" :: Text, eid)
      abandon eid  -- @after
      updated <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "DraftSession not found after update")

transitionCompletedToDrafting :: Int -> IO DraftSession
transitionCompletedToDrafting eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
  case rows of
    [] -> throwIO (userError "DraftSession not found")
    (record:_) -> do
      throwIO (userError "Transition Completed -> Drafting is not allowed")

transitionAbandonedToDrafting :: Int -> IO DraftSession
transitionAbandonedToDrafting eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, draft_type, seats, time_per_pick_seconds, created_at, completed_at, card_set_id, participants_id FROM draft_sessions WHERE id = ?" (Only eid) :: IO [DraftSession]
  case rows of
    [] -> throwIO (userError "DraftSession not found")
    (record:_) -> do
      throwIO (userError "Transition Abandoned -> Drafting is not allowed")

