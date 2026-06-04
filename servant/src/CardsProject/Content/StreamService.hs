{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.StreamService
  ( validateStream, go_live, end, update_viewer_peak, duration_minutes, enumToText, assertTransition, allowedTransitions, transitionScheduledToLive, transitionLiveToEnded, transitionEndedToLive
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import qualified Data.Text
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for Stream
validateStream :: NewStream -> Either String NewStream
validateStream body
  | not (bStreamViewerCountPeak body >= 0) = Left "Peak viewer count must not be negative"
  | otherwise = validateStreamImplies body

validateStreamImplies :: NewStream -> Either String NewStream
validateStreamImplies body
  | (bStreamActualStart body /= Nothing) && not (bStreamStatus body == StreamStatusType_Live) = Left "actual start requires live or ended"
  | (bStreamEndedAt body /= Nothing) && not (bStreamStatus body == StreamStatusType_Ended) = Left "ended_at can only be set when stream status is Ended"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
go_live :: Int -> IO ()
go_live _eid = throwIO (userError "go_live not implemented")

-- @invoke behavior stub (no-op)
end :: Int -> IO ()
end _eid = throwIO (userError "end not implemented")

-- @invoke behavior stub (no-op)
update_viewer_peak :: Int -> IO ()
update_viewer_peak _eid = throwIO (userError "update_viewer_peak not implemented")

-- @invoke behavior stub (no-op)
duration_minutes :: Int -> IO Int
duration_minutes _eid = throwIO (userError "duration_minutes not implemented")

-- ── Lifecycle state machine ─────────────────────────────────────────
allowedTransitions :: [(Text, [Text])]
allowedTransitions =
  [   ("Scheduled", ["Live"])
  ,  ("Live", ["Ended"])
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

transitionScheduledToLive :: Int -> IO Stream
transitionScheduledToLive eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
  case rows of
    [] -> throwIO (userError "Stream not found")
    (record:_) -> do
      assertTransition (enumToText (streamStatus record)) "Live"
      execute conn "UPDATE streams SET status = ? WHERE id = ?" ("Live" :: Text, eid)
      go_live eid  -- @after
      updated <- query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Stream not found after update")

transitionLiveToEnded :: Int -> IO Stream
transitionLiveToEnded eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
  case rows of
    [] -> throwIO (userError "Stream not found")
    (record:_) -> do
      assertTransition (enumToText (streamStatus record)) "Ended"
      execute conn "UPDATE streams SET status = ? WHERE id = ?" ("Ended" :: Text, eid)
      end eid  -- @after
      updated <- query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Stream not found after update")

transitionEndedToLive :: Int -> IO Stream
transitionEndedToLive eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
  case rows of
    [] -> throwIO (userError "Stream not found")
    (record:_) -> do
      throwIO (userError "Transition Ended -> Live is not allowed")

