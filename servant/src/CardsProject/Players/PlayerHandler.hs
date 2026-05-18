{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Players.PlayerHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Players.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Players.PlayerService as PlayerSvc
import Data.Aeson (Object)
import Data.Text (Text)

type PlayerAPI
  =    "api" :> "players" :> Get '[JSON] [Player]
  :<|> "api" :> "players" :> ReqBody '[JSON] NewPlayer :> PostCreated '[JSON] Player
  :<|> "api" :> "players" :> Capture "id" Int :> Get '[JSON] Player
  :<|> "api" :> "players" :> Capture "id" Int :> ReqBody '[JSON] NewPlayer :> Put '[JSON] Player
  :<|> "api" :> "players" :> Capture "id" Int :> ReqBody '[JSON] NewPlayer :> Patch '[JSON] Player
  :<|> "api" :> "players" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "players" :> Capture "id" Int :> "promote" :> Post '[JSON] Bool
  :<|> "api" :> "players" :> Capture "id" Int :> "demote" :> Post '[JSON] Bool
  :<|> "api" :> "players" :> Capture "id" Int :> "win" :> Post '[JSON] NoContent
  :<|> "api" :> "players" :> Capture "id" Int :> "loss" :> Post '[JSON] NoContent
  :<|> "api" :> "players" :> Capture "id" Int :> "win-rate" :> Get '[JSON] Text
  :<|> "api" :> "players" :> Capture "id" Int :> "verify" :> Post '[JSON] NoContent
  :<|> "api" :> "players" :> Capture "id" Int :> "rating" :> ReqBody '[JSON] Object :> Patch '[JSON] NoContent

playerServer :: Server PlayerAPI
playerServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorPromote
  :<|> behaviorDemote
  :<|> behaviorRecordWin
  :<|> behaviorRecordLoss
  :<|> behaviorWinRate
  :<|> behaviorVerify
  :<|> behaviorUpdateRating
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players" :: IO [Player]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO players (display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Player]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE players SET display_name = ?, rank = ?, rating = ?, peak_rating = ?, bio = ?, country_code = ?, avatar_url = ?, preferred_format = ?, is_verified = ?, created_at = ?, last_active_at = ?, user_id = ?, season_stats_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM players WHERE id = ?" (Only eid)
      return NoContent

    behaviorPromote eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ PlayerSvc.promote eid
          return result

    behaviorDemote eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ PlayerSvc.demote eid
          return result

    behaviorRecordWin eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ PlayerSvc.record_win eid
          return NoContent

    behaviorRecordLoss eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ PlayerSvc.record_loss eid
          return NoContent

    behaviorWinRate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ PlayerSvc.win_rate eid
          return result

    behaviorVerify eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ PlayerSvc.verify eid
          return NoContent

    behaviorUpdateRating eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id, season_stats_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ PlayerSvc.update_rating eid
          return NoContent

