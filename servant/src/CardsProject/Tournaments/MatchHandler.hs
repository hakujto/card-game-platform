{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Tournaments.MatchHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Tournaments.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Tournaments.MatchService as MatchSvc
import Data.Aeson (Object)
import Data.Text (Text)

type MatchAPI
  =    "api" :> "matches" :> Get '[JSON] [Match]
  :<|> "api" :> "matches" :> ReqBody '[JSON] NewMatch :> PostCreated '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> Get '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> ReqBody '[JSON] NewMatch :> Put '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> ReqBody '[JSON] NewMatch :> Patch '[JSON] Match
  :<|> "api" :> "matches" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "matches" :> Capture "id" Int :> "record" :> ReqBody '[JSON] Object :> Post '[JSON] NoContent
  :<|> "api" :> "matches" :> Capture "id" Int :> "winner" :> Get '[JSON] Bool
  :<|> "api" :> "matches" :> Capture "id" Int :> "concede" :> ReqBody '[JSON] Object :> Post '[JSON] NoContent
  :<|> "api" :> "matches" :> Capture "id" Int :> "draw" :> Post '[JSON] NoContent

matchServer :: Server MatchAPI
matchServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorRecordResult
  :<|> behaviorDetermineWinner
  :<|> behaviorConcede
  :<|> behaviorDraw
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id FROM matches" :: IO [Match]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO matches (table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id FROM matches WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Match]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE matches SET table_number = ?, status = ?, player1_wins = ?, player2_wins = ?, started_at = ?, ended_at = ?, result_notes = ?, round_id = ?, player1_id = ?, player2_id = ?, games_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM matches WHERE id = ?" (Only eid)
      return NoContent

    behaviorRecordResult eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ MatchSvc.record_result eid
          return NoContent

    behaviorDetermineWinner eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ MatchSvc.determine_winner eid
          return result

    behaviorConcede eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ MatchSvc.concede eid
          return NoContent

    behaviorDraw eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, games_id FROM matches WHERE id = ?" (Only eid) :: IO [Match]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ MatchSvc.draw eid
          return NoContent

