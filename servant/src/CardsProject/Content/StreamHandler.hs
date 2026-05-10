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

type StreamAPI
  =    "api" :> "streams" :> Get '[JSON] [Stream]
  :<|> "api" :> "streams" :> ReqBody '[JSON] NewStream :> PostCreated '[JSON] Stream
  :<|> "api" :> "streams" :> Capture "id" Int :> Get '[JSON] Stream
  :<|> "api" :> "streams" :> Capture "id" Int :> ReqBody '[JSON] NewStream :> Put '[JSON] Stream
  :<|> "api" :> "streams" :> Capture "id" Int :> ReqBody '[JSON] NewStream :> Patch '[JSON] Stream
  :<|> "api" :> "streams" :> Capture "id" Int :> DeleteNoContent

streamServer :: Server StreamAPI
streamServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, title, stream_url, platform, status, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams" :: IO [Stream]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO streams (title, stream_url, platform, status, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, title, stream_url, platform, status, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Stream]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, stream_url, platform, status, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE streams SET title = ?, stream_url = ?, platform = ?, status = ?, viewer_count_peak = ?, scheduled_start = ?, actual_start = ?, ended_at = ?, vod_url = ?, tournament_id = ?, streamer_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, title, stream_url, platform, status, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id FROM streams WHERE id = ?" (Only eid) :: IO [Stream]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM streams WHERE id = ?" (Only eid)
      return NoContent

