{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Tournaments.TournamentPrizeHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Tournaments.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Tournaments.TournamentPrizeService as TournamentPrizeSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type TournamentPrizeAPI
  =    "api" :> "tournament_prizes" :> Get '[JSON] [TournamentPrize]
  :<|> "api" :> "tournament_prizes" :> ReqBody '[JSON] NewTournamentPrize :> PostCreated '[JSON] TournamentPrize
  :<|> "api" :> "tournament_prizes" :> Capture "id" Int :> Get '[JSON] TournamentPrize
  :<|> "api" :> "tournament_prizes" :> Capture "id" Int :> ReqBody '[JSON] NewTournamentPrize :> Put '[JSON] TournamentPrize
  :<|> "api" :> "tournament_prizes" :> Capture "id" Int :> ReqBody '[JSON] NewTournamentPrize :> Patch '[JSON] TournamentPrize
  :<|> "api" :> "tournament_prizes" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "tournament_prizes" :> Capture "id" Int :> "applies" :> Get '[JSON] Bool
  :<|> "api" :> "tournament_prizes" :> Capture "id" Int :> "award" :> ReqBody '[JSON] Object :> PostNoContent

tournamentPrizeServer :: Server TournamentPrizeAPI
tournamentPrizeServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorAppliesToPlacement
  :<|> behaviorAwardToPlayer
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id FROM tournament_prizes" :: IO [TournamentPrize]

    create body = do
      case TournamentPrizeSvc.validateTournamentPrize body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO tournament_prizes (placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id FROM tournament_prizes WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TournamentPrize]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id FROM tournament_prizes WHERE id = ?" (Only eid) :: IO [TournamentPrize]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      case TournamentPrizeSvc.validateTournamentPrize body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = toRow validBody ++ toRow (Only eid)
            execute conn "UPDATE tournament_prizes SET placement_from = ?, placement_to = ?, prize_type = ?, amount = ?, description = ?, packs_count = ?, season_points = ?, tournament_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id FROM tournament_prizes WHERE id = ?" (Only eid) :: IO [TournamentPrize]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM tournament_prizes WHERE id = ?" (Only eid)
      return NoContent

    behaviorAppliesToPlacement eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id FROM tournament_prizes WHERE id = ?" (Only eid) :: IO [TournamentPrize]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentPrizeSvc.applies_to_placement eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorAwardToPlayer eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id FROM tournament_prizes WHERE id = ?" (Only eid) :: IO [TournamentPrize]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TournamentPrizeSvc.award_to_player eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

