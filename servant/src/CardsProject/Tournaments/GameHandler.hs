{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Tournaments.GameHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Tournaments.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Tournaments.GameService as GameSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type GameAPI
  =    "api" :> "games" :> Get '[JSON] [Game]
  :<|> "api" :> "games" :> ReqBody '[JSON] NewGame :> PostCreated '[JSON] Game
  :<|> "api" :> "games" :> Capture "id" Int :> Get '[JSON] Game
  :<|> "api" :> "games" :> Capture "id" Int :> "winner" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "games" :> Capture "id" Int :> "duration" :> Get '[JSON] Text

gameServer :: Server GameAPI
gameServer = listAll
  :<|> create
  :<|> getOne
  :<|> behaviorRecordWinner
  :<|> behaviorDurationMinutes
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id FROM games" :: IO [Game]

    create body = do
      case GameSvc.validateGame body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO games (game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id FROM games WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Game]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id FROM games WHERE id = ?" (Only eid) :: IO [Game]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorRecordWinner eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id FROM games WHERE id = ?" (Only eid) :: IO [Game]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> GameSvc.record_winner eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDurationMinutes eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id FROM games WHERE id = ?" (Only eid) :: IO [Game]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> GameSvc.duration_minutes eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

