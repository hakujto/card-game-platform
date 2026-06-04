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
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Text (Text)

type AwardedPrizeAPI
  =    "api" :> "awarded_prizes" :> Get '[JSON] [AwardedPrize]
  :<|> "api" :> "awarded_prizes" :> Capture "id" Int :> Get '[JSON] AwardedPrize
  :<|> "api" :> "awarded_prizes" :> Capture "id" Int :> "claim" :> PostNoContent

awardedPrizeServer :: Server AwardedPrizeAPI
awardedPrizeServer = listAll
  :<|> getOne
  :<|> behaviorClaim
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id FROM awarded_prizes" :: IO [AwardedPrize]

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id FROM awarded_prizes WHERE id = ?" (Only eid) :: IO [AwardedPrize]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorClaim eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id FROM awarded_prizes WHERE id = ?" (Only eid) :: IO [AwardedPrize]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> AwardedPrizeSvc.claim eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

