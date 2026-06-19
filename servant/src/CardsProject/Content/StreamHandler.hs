{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Content.StreamHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Content.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Content.StreamService as StreamSvc
import qualified Data.ByteString.Lazy.Char8
import Data.Text (Text)
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type StreamAPI
  =    "api" :> "streams" :> QueryParam "q" Text :> Get '[JSON] [Stream]
  :<|> "api" :> "streams" :> ReqBody '[JSON] NewStream :> PostCreated '[JSON] Stream
  :<|> "api" :> "streams" :> Capture "id" Int :> Get '[JSON] Stream
  :<|> "api" :> "streams" :> Capture "id" Int :> ReqBody '[JSON] NewStream :> Put '[JSON] Stream
  :<|> "api" :> "streams" :> Capture "id" Int :> ReqBody '[JSON] NewStream :> Patch '[JSON] Stream
  :<|> "api" :> "streams" :> Capture "id" Int :> "live" :> PostNoContent
  :<|> "api" :> "streams" :> Capture "id" Int :> "end" :> PostNoContent
  :<|> "api" :> "streams" :> Capture "id" Int :> "viewers" :> ReqBody '[JSON] Object :> PatchNoContent
  :<|> "api" :> "streams" :> Capture "id" Int :> "duration" :> Get '[JSON] Int
  :<|> "api" :> "streams" :> Capture "id" Int :> "transitions" :> "scheduled-to-live" :> Header "X-User-Role" Text :> Patch '[JSON] Stream
  :<|> "api" :> "streams" :> Capture "id" Int :> "transitions" :> "live-to-ended" :> Header "X-User-Role" Text :> Patch '[JSON] Stream
  :<|> "api" :> "streams" :> Capture "id" Int :> "transitions" :> "ended-to-live" :> Patch '[JSON] Stream

streamServer :: Server StreamAPI
streamServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> behaviorGoLive
  :<|> behaviorEnd
  :<|> behaviorUpdateViewerPeak
  :<|> behaviorDurationMinutes
  :<|> transitionHandlerScheduledToLive
  :<|> transitionHandlerLiveToEnded
  :<|> transitionHandlerEndedToLive
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams" :: IO [Stream]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE title LIKE ?" (Only qp) :: IO [Stream]

    create body = do
      case StreamSvc.validateStream body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO streams (title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Stream]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      case StreamSvc.validateStream body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = toRow validBody ++ toRow (Only eid)
            execute conn "UPDATE streams SET title = ?, stream_url = ?, status = ?, platform = ?, language = ?, is_official = ?, viewer_count_peak = ?, scheduled_start = ?, actual_start = ?, ended_at = ?, vod_url = ?, tournament_id = ?, streamer_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    behaviorGoLive eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> StreamSvc.go_live eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorEnd eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> StreamSvc.end eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorUpdateViewerPeak eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> StreamSvc.update_viewer_peak eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDurationMinutes eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> StreamSvc.duration_minutes eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    transitionHandlerScheduledToLive eid mRole = do
      let allowedRoles = ["Streamer", "Admin"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (StreamSvc.transitionScheduledToLive eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerLiveToEnded eid mRole = do
      let allowedRoles = ["Streamer", "Admin"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (StreamSvc.transitionLiveToEnded eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerEndedToLive eid = do
      result <- liftIO $ (StreamSvc.transitionEndedToLive eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

