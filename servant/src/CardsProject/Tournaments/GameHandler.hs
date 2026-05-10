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

type GameAPI
  =    "api" :> "games" :> Get '[JSON] [Game]
  :<|> "api" :> "games" :> ReqBody '[JSON] NewGame :> PostCreated '[JSON] Game
  :<|> "api" :> "games" :> Capture "id" Int :> Get '[JSON] Game
  :<|> "api" :> "games" :> Capture "id" Int :> ReqBody '[JSON] NewGame :> Put '[JSON] Game
  :<|> "api" :> "games" :> Capture "id" Int :> ReqBody '[JSON] NewGame :> Patch '[JSON] Game
  :<|> "api" :> "games" :> Capture "id" Int :> DeleteNoContent

gameServer :: Server GameAPI
gameServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, game_number, winner_side, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id FROM games" :: IO [Game]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO games (game_number, winner_side, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, game_number, winner_side, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id FROM games WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Game]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, game_number, winner_side, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id FROM games WHERE id = ?" (Only eid) :: IO [Game]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE games SET game_number = ?, winner_side = ?, turns_played = ?, duration_seconds = ?, ended_by = ?, replay_url = ?, match_id = ?, winner_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, game_number, winner_side, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id FROM games WHERE id = ?" (Only eid) :: IO [Game]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM games WHERE id = ?" (Only eid)
      return NoContent

