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

type TournamentPrizeAPI
  =    "api" :> "tournament_prizes" :> Get '[JSON] [TournamentPrize]
  :<|> "api" :> "tournament_prizes" :> ReqBody '[JSON] NewTournamentPrize :> PostCreated '[JSON] TournamentPrize
  :<|> "api" :> "tournament_prizes" :> Capture "id" Int :> Get '[JSON] TournamentPrize
  :<|> "api" :> "tournament_prizes" :> Capture "id" Int :> ReqBody '[JSON] NewTournamentPrize :> Put '[JSON] TournamentPrize
  :<|> "api" :> "tournament_prizes" :> Capture "id" Int :> ReqBody '[JSON] NewTournamentPrize :> Patch '[JSON] TournamentPrize
  :<|> "api" :> "tournament_prizes" :> Capture "id" Int :> DeleteNoContent

tournamentPrizeServer :: Server TournamentPrizeAPI
tournamentPrizeServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id FROM tournament_prizes" :: IO [TournamentPrize]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO tournament_prizes (placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)" body
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
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
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

