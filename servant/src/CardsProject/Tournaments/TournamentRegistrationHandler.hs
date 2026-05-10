{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Tournaments.TournamentRegistrationHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Tournaments.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type TournamentRegistrationAPI
  =    "api" :> "tournament_registrations" :> Get '[JSON] [TournamentRegistration]
  :<|> "api" :> "tournament_registrations" :> ReqBody '[JSON] NewTournamentRegistration :> PostCreated '[JSON] TournamentRegistration
  :<|> "api" :> "tournament_registrations" :> Capture "id" Int :> Get '[JSON] TournamentRegistration
  :<|> "api" :> "tournament_registrations" :> Capture "id" Int :> ReqBody '[JSON] NewTournamentRegistration :> Put '[JSON] TournamentRegistration
  :<|> "api" :> "tournament_registrations" :> Capture "id" Int :> ReqBody '[JSON] NewTournamentRegistration :> Patch '[JSON] TournamentRegistration
  :<|> "api" :> "tournament_registrations" :> Capture "id" Int :> DeleteNoContent

tournamentRegistrationServer :: Server TournamentRegistrationAPI
tournamentRegistrationServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id FROM tournament_registrations" :: IO [TournamentRegistration]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO tournament_registrations (status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id FROM tournament_registrations WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TournamentRegistration]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id FROM tournament_registrations WHERE id = ?" (Only eid) :: IO [TournamentRegistration]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE tournament_registrations SET status = ?, seed = ?, final_standing = ?, points_earned = ?, registered_at = ?, tournament_id = ?, player_id = ?, deck_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id FROM tournament_registrations WHERE id = ?" (Only eid) :: IO [TournamentRegistration]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM tournament_registrations WHERE id = ?" (Only eid)
      return NoContent

