{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeDisputeService
  ( validateTradeDispute, escalate, resolve, close_resolved, review, enumToText, assertTransition, allowedTransitions, transitionOpenToUnderReview, transitionUnderReviewToResolved, transitionUnderReviewToEscalated, transitionEscalatedToResolved, transitionResolvedToOpen
  ) where

import CardsProject.Marketplace.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import qualified Data.Text
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for TradeDispute
validateTradeDispute :: NewTradeDispute -> Either String NewTradeDispute
validateTradeDispute body = validateTradeDisputeImplies body

validateTradeDisputeImplies :: NewTradeDispute -> Either String NewTradeDispute
validateTradeDisputeImplies body
  | (bTradeDisputeResolvedAt body /= Nothing) && not (bTradeDisputeStatus body == TradeDisputeStatusType_Resolved) = Left "resolved at requires terminal status"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
escalate :: Int -> IO ()
escalate _eid = throwIO (userError "escalate not implemented")

-- @invoke behavior stub (no-op)
resolve :: Int -> IO ()
resolve _eid = throwIO (userError "resolve not implemented")

-- @invoke behavior stub (no-op)
close_resolved :: Int -> IO ()
close_resolved _eid = throwIO (userError "close_resolved not implemented")

-- @invoke behavior stub (no-op)
review :: Int -> IO ()
review _eid = throwIO (userError "review not implemented")

-- ── Lifecycle state machine ─────────────────────────────────────────
allowedTransitions :: [(Text, [Text])]
allowedTransitions =
  [   ("Open", ["UnderReview"])
  ,  ("UnderReview", ["Resolved", "Escalated"])
  ,  ("Escalated", ["Resolved"])
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

transitionOpenToUnderReview :: Int -> IO TradeDispute
transitionOpenToUnderReview eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
  case rows of
    [] -> throwIO (userError "TradeDispute not found")
    (record:_) -> do
      assertTransition (enumToText (tradeDisputeStatus record)) "UnderReview"
      execute conn "UPDATE trade_disputes SET status = ? WHERE id = ?" ("UnderReview" :: Text, eid)
      review eid  -- @after
      updated <- query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "TradeDispute not found after update")

transitionUnderReviewToResolved :: Int -> IO TradeDispute
transitionUnderReviewToResolved eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
  case rows of
    [] -> throwIO (userError "TradeDispute not found")
    (record:_) -> do
      assertTransition (enumToText (tradeDisputeStatus record)) "Resolved"
      case tradeDisputeResolution record of
        Nothing -> throwIO (userError "resolution is required for UnderReview -> Resolved")
        Just _  -> return ()
      execute conn "UPDATE trade_disputes SET status = ? WHERE id = ?" ("Resolved" :: Text, eid)
      close_resolved eid  -- @after
      updated <- query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "TradeDispute not found after update")

transitionUnderReviewToEscalated :: Int -> IO TradeDispute
transitionUnderReviewToEscalated eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
  case rows of
    [] -> throwIO (userError "TradeDispute not found")
    (record:_) -> do
      assertTransition (enumToText (tradeDisputeStatus record)) "Escalated"
      execute conn "UPDATE trade_disputes SET status = ? WHERE id = ?" ("Escalated" :: Text, eid)
      escalate eid  -- @after
      updated <- query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "TradeDispute not found after update")

transitionEscalatedToResolved :: Int -> IO TradeDispute
transitionEscalatedToResolved eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
  case rows of
    [] -> throwIO (userError "TradeDispute not found")
    (record:_) -> do
      assertTransition (enumToText (tradeDisputeStatus record)) "Resolved"
      case tradeDisputeResolution record of
        Nothing -> throwIO (userError "resolution is required for Escalated -> Resolved")
        Just _  -> return ()
      execute conn "UPDATE trade_disputes SET status = ? WHERE id = ?" ("Resolved" :: Text, eid)
      close_resolved eid  -- @after
      updated <- query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "TradeDispute not found after update")

transitionResolvedToOpen :: Int -> IO TradeDispute
transitionResolvedToOpen eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
  case rows of
    [] -> throwIO (userError "TradeDispute not found")
    (record:_) -> do
      throwIO (userError "Transition Resolved -> Open is not allowed")

