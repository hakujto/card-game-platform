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
import qualified CardsProject.Tournaments.TournamentRegistrationService as TournamentRegistrationSvc
import qualified Data.ByteString.Lazy.Char8
import Data.Text (Text)
import qualified Data.Text
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type TournamentRegistrationAPI
  =    "api" :> "tournament_registrations" :> Get '[JSON] [TournamentRegistration]
  :<|> "api" :> "tournament_registrations" :> ReqBody '[JSON] NewTournamentRegistration :> PostCreated '[JSON] TournamentRegistration
  :<|> "api" :> "tournament_registrations" :> Capture "id" Int :> Header "X-User-Id" Text :> Get '[JSON] TournamentRegistration
  :<|> "api" :> "tournament_registrations" :> Capture "id" Int :> "withdraw" :> PostNoContent
  :<|> "api" :> "tournament_registrations" :> Capture "id" Int :> "disqualify" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "tournament_registrations" :> Capture "id" Int :> "promote" :> PostNoContent

tournamentRegistrationServer :: Server TournamentRegistrationAPI
tournamentRegistrationServer = listAll
  :<|> create
  :<|> getOne
  :<|> behaviorWithdraw
  :<|> behaviorDisqualify
  :<|> behaviorPromoteFromWaitlist
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id FROM tournament_registrations" :: IO [TournamentRegistration]

    create body = do
      case TournamentRegistrationSvc.validateTournamentRegistration body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO tournament_registrations (status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id FROM tournament_registrations WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TournamentRegistration]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid mUserId = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id FROM tournament_registrations WHERE id = ?" (Only eid) :: IO [TournamentRegistration]
      case rows of
        (r:_) -> case mUserId of
          Nothing  -> throwError err401
          Just uid -> if tournamentRegistrationPlayerId r /= Just (read (Data.Text.unpack uid) :: Int)
            then throwError err403
            else return r
        []    -> throwError err404

    behaviorWithdraw eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id FROM tournament_registrations WHERE id = ?" (Only eid) :: IO [TournamentRegistration]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentRegistrationSvc.withdraw eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDisqualify eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id FROM tournament_registrations WHERE id = ?" (Only eid) :: IO [TournamentRegistration]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentRegistrationSvc.disqualify eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorPromoteFromWaitlist eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id FROM tournament_registrations WHERE id = ?" (Only eid) :: IO [TournamentRegistration]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentRegistrationSvc.promote_from_waitlist eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

