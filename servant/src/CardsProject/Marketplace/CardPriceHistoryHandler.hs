{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.CardPriceHistoryHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Marketplace.CardPriceHistoryService as CardPriceHistorySvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Text (Text)

type CardPriceHistoryAPI
  =    "api" :> "card_price_histories" :> Get '[JSON] [CardPriceHistory]
  :<|> "api" :> "card_price_histories" :> Capture "id" Int :> Get '[JSON] CardPriceHistory
  :<|> "api" :> "card_price_histories" :> Capture "id" Int :> "change" :> Get '[JSON] Text
  :<|> "api" :> "card_price_histories" :> Capture "id" Int :> "spike" :> Get '[JSON] Bool

cardPriceHistoryServer :: Server CardPriceHistoryAPI
cardPriceHistoryServer = listAll
  :<|> getOne
  :<|> behaviorPriceChangePercent
  :<|> behaviorIsPriceSpike
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id FROM card_price_histories" :: IO [CardPriceHistory]

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id FROM card_price_histories WHERE id = ?" (Only eid) :: IO [CardPriceHistory]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorPriceChangePercent eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id FROM card_price_histories WHERE id = ?" (Only eid) :: IO [CardPriceHistory]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardPriceHistorySvc.price_change_percent eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorIsPriceSpike eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id FROM card_price_histories WHERE id = ?" (Only eid) :: IO [CardPriceHistory]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardPriceHistorySvc.is_price_spike eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

