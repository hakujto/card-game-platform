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
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type PlayerAPI
  =    "api" :> "players" :> QueryParam "q" Text :> Get '[JSON] [Player]
  :<|> "api" :> "players" :> ReqBody '[JSON] NewPlayer :> PostCreated '[JSON] Player
  :<|> "api" :> "players" :> Capture "id" Int :> Get '[JSON] Player
  :<|> "api" :> "players" :> Capture "id" Int :> ReqBody '[JSON] NewPlayer :> Patch '[JSON] Player
  :<|> "api" :> "players" :> Capture "id" Int :> "promote" :> Post '[JSON] Bool
  :<|> "api" :> "players" :> Capture "id" Int :> "demote" :> Post '[JSON] Bool
  :<|> "api" :> "players" :> Capture "id" Int :> "win" :> PostNoContent
  :<|> "api" :> "players" :> Capture "id" Int :> "loss" :> PostNoContent
  :<|> "api" :> "players" :> Capture "id" Int :> "win-rate" :> Get '[JSON] Text
  :<|> "api" :> "players" :> Capture "id" Int :> "verify" :> PostNoContent
  :<|> "api" :> "players" :> Capture "id" Int :> "rating" :> ReqBody '[JSON] Object :> PatchNoContent

playerServer :: Server PlayerAPI
playerServer = listAll
  :<|> create
  :<|> getOne
  :<|> partialUpdate
  :<|> behaviorPromote
  :<|> behaviorDemote
  :<|> behaviorRecordWin
  :<|> behaviorRecordLoss
  :<|> behaviorWinRate
  :<|> behaviorVerify
  :<|> behaviorUpdateRating
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players" :: IO [Player]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE display_name LIKE ?" (Only qp) :: IO [Player]

    create body = do
      case PlayerSvc.validatePlayer body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO players (display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Player]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate eid body = do
      case PlayerSvc.validatePlayer body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = toRow validBody ++ toRow (Only eid)
            execute conn "UPDATE players SET display_name = ?, rank = ?, rating = ?, peak_rating = ?, bio = ?, country_code = ?, avatar_url = ?, preferred_format = ?, is_verified = ?, created_at = ?, last_active_at = ?, user_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    behaviorPromote eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerSvc.promote eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorDemote eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerSvc.demote eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorRecordWin eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerSvc.record_win eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorRecordLoss eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerSvc.record_loss eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorWinRate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerSvc.win_rate eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorVerify eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerSvc.verify eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorUpdateRating eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, created_at, last_active_at, user_id FROM players WHERE id = ?" (Only eid) :: IO [Player]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> PlayerSvc.update_rating eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

