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

type CardPriceHistoryAPI
  =    "api" :> "card_price_histories" :> Get '[JSON] [CardPriceHistory]
  :<|> "api" :> "card_price_histories" :> ReqBody '[JSON] NewCardPriceHistory :> PostCreated '[JSON] CardPriceHistory
  :<|> "api" :> "card_price_histories" :> Capture "id" Int :> Get '[JSON] CardPriceHistory
  :<|> "api" :> "card_price_histories" :> Capture "id" Int :> ReqBody '[JSON] NewCardPriceHistory :> Put '[JSON] CardPriceHistory
  :<|> "api" :> "card_price_histories" :> Capture "id" Int :> ReqBody '[JSON] NewCardPriceHistory :> Patch '[JSON] CardPriceHistory
  :<|> "api" :> "card_price_histories" :> Capture "id" Int :> DeleteNoContent

cardPriceHistoryServer :: Server CardPriceHistoryAPI
cardPriceHistoryServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id FROM card_price_histories" :: IO [CardPriceHistory]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO card_price_histories (price_date, avg_price, min_price, max_price, volume, foil, card_id) VALUES (?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id FROM card_price_histories WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [CardPriceHistory]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id FROM card_price_histories WHERE id = ?" (Only eid) :: IO [CardPriceHistory]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE card_price_histories SET price_date = ?, avg_price = ?, min_price = ?, max_price = ?, volume = ?, foil = ?, card_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id FROM card_price_histories WHERE id = ?" (Only eid) :: IO [CardPriceHistory]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM card_price_histories WHERE id = ?" (Only eid)
      return NoContent

