{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.CardRulingHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type CardRulingAPI
  =    "api" :> "card_rulings" :> Get '[JSON] [CardRuling]
  :<|> "api" :> "card_rulings" :> ReqBody '[JSON] NewCardRuling :> PostCreated '[JSON] CardRuling
  :<|> "api" :> "card_rulings" :> Capture "id" Int :> Get '[JSON] CardRuling
  :<|> "api" :> "card_rulings" :> Capture "id" Int :> ReqBody '[JSON] NewCardRuling :> Put '[JSON] CardRuling
  :<|> "api" :> "card_rulings" :> Capture "id" Int :> ReqBody '[JSON] NewCardRuling :> Patch '[JSON] CardRuling
  :<|> "api" :> "card_rulings" :> Capture "id" Int :> DeleteNoContent

cardRulingServer :: Server CardRulingAPI
cardRulingServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, ruling_text, published_at, source, card_id FROM card_rulings" :: IO [CardRuling]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO card_rulings (ruling_text, published_at, source, card_id) VALUES (?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, ruling_text, published_at, source, card_id FROM card_rulings WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [CardRuling]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, ruling_text, published_at, source, card_id FROM card_rulings WHERE id = ?" (Only eid) :: IO [CardRuling]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE card_rulings SET ruling_text = ?, published_at = ?, source = ?, card_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, ruling_text, published_at, source, card_id FROM card_rulings WHERE id = ?" (Only eid) :: IO [CardRuling]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM card_rulings WHERE id = ?" (Only eid)
      return NoContent

