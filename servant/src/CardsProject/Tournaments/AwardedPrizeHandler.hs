{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Tournaments.AwardedPrizeHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Tournaments.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Tournaments.AwardedPrizeService as AwardedPrizeSvc
import Data.Text (Text)

type AwardedPrizeAPI
  =    "api" :> "awarded_prizes" :> Get '[JSON] [AwardedPrize]
  :<|> "api" :> "awarded_prizes" :> ReqBody '[JSON] NewAwardedPrize :> PostCreated '[JSON] AwardedPrize
  :<|> "api" :> "awarded_prizes" :> Capture "id" Int :> Get '[JSON] AwardedPrize
  :<|> "api" :> "awarded_prizes" :> Capture "id" Int :> ReqBody '[JSON] NewAwardedPrize :> Put '[JSON] AwardedPrize
  :<|> "api" :> "awarded_prizes" :> Capture "id" Int :> ReqBody '[JSON] NewAwardedPrize :> Patch '[JSON] AwardedPrize
  :<|> "api" :> "awarded_prizes" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "awarded_prizes" :> Capture "id" Int :> "claim" :> Post '[JSON] NoContent

awardedPrizeServer :: Server AwardedPrizeAPI
awardedPrizeServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorClaim
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id FROM awarded_prizes" :: IO [AwardedPrize]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO awarded_prizes (final_placement, awarded_at, claimed, claimed_at, prize_id, player_id) VALUES (?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id FROM awarded_prizes WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [AwardedPrize]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id FROM awarded_prizes WHERE id = ?" (Only eid) :: IO [AwardedPrize]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE awarded_prizes SET final_placement = ?, awarded_at = ?, claimed = ?, claimed_at = ?, prize_id = ?, player_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id FROM awarded_prizes WHERE id = ?" (Only eid) :: IO [AwardedPrize]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM awarded_prizes WHERE id = ?" (Only eid)
      return NoContent

    behaviorClaim eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id FROM awarded_prizes WHERE id = ?" (Only eid) :: IO [AwardedPrize]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ AwardedPrizeSvc.claim eid
          return NoContent

