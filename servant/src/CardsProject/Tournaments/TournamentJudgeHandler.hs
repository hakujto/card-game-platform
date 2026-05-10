{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Tournaments.TournamentJudgeHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Tournaments.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type TournamentJudgeAPI
  =    "api" :> "tournament_judges" :> Get '[JSON] [TournamentJudge]
  :<|> "api" :> "tournament_judges" :> ReqBody '[JSON] NewTournamentJudge :> PostCreated '[JSON] TournamentJudge
  :<|> "api" :> "tournament_judges" :> Capture "id" Int :> Get '[JSON] TournamentJudge
  :<|> "api" :> "tournament_judges" :> Capture "id" Int :> ReqBody '[JSON] NewTournamentJudge :> Put '[JSON] TournamentJudge
  :<|> "api" :> "tournament_judges" :> Capture "id" Int :> ReqBody '[JSON] NewTournamentJudge :> Patch '[JSON] TournamentJudge
  :<|> "api" :> "tournament_judges" :> Capture "id" Int :> DeleteNoContent

tournamentJudgeServer :: Server TournamentJudgeAPI
tournamentJudgeServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, role, tournament_id, player_id FROM tournament_judges" :: IO [TournamentJudge]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO tournament_judges (role, tournament_id, player_id) VALUES (?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, role, tournament_id, player_id FROM tournament_judges WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TournamentJudge]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, role, tournament_id, player_id FROM tournament_judges WHERE id = ?" (Only eid) :: IO [TournamentJudge]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE tournament_judges SET role = ?, tournament_id = ?, player_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, role, tournament_id, player_id FROM tournament_judges WHERE id = ?" (Only eid) :: IO [TournamentJudge]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM tournament_judges WHERE id = ?" (Only eid)
      return NoContent

