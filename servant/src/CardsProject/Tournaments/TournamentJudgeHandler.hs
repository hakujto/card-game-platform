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
import qualified CardsProject.Tournaments.TournamentJudgeService as TournamentJudgeSvc
import Control.Exception (catch, IOException)
import Data.Text (Text)

type TournamentJudgeAPI
  =    "api" :> "tournament_judges" :> Get '[JSON] [TournamentJudge]
  :<|> "api" :> "tournament_judges" :> ReqBody '[JSON] NewTournamentJudge :> PostCreated '[JSON] TournamentJudge
  :<|> "api" :> "tournament_judges" :> Capture "id" Int :> Get '[JSON] TournamentJudge
  :<|> "api" :> "tournament_judges" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "tournament_judges" :> Capture "id" Int :> "promote" :> PostNoContent
  :<|> "api" :> "tournament_judges" :> Capture "id" Int :> DeleteNoContent

tournamentJudgeServer :: Server TournamentJudgeAPI
tournamentJudgeServer = listAll
  :<|> create
  :<|> getOne
  :<|> delete
  :<|> behaviorPromoteToHead
  :<|> behaviorRemove
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

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM tournament_judges WHERE id = ?" (Only eid)
      return NoContent

    behaviorPromoteToHead eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, role, tournament_id, player_id FROM tournament_judges WHERE id = ?" (Only eid) :: IO [TournamentJudge]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentJudgeSvc.promote_to_head eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorRemove eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, role, tournament_id, player_id FROM tournament_judges WHERE id = ?" (Only eid) :: IO [TournamentJudge]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentJudgeSvc.remove eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

