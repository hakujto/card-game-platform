{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.CardSetHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type CardSetAPI
  =    "api" :> "card_sets" :> Get '[JSON] [CardSet]
  :<|> "api" :> "card_sets" :> ReqBody '[JSON] NewCardSet :> PostCreated '[JSON] CardSet
  :<|> "api" :> "card_sets" :> Capture "id" Int :> Get '[JSON] CardSet
  :<|> "api" :> "card_sets" :> Capture "id" Int :> ReqBody '[JSON] NewCardSet :> Put '[JSON] CardSet
  :<|> "api" :> "card_sets" :> Capture "id" Int :> ReqBody '[JSON] NewCardSet :> Patch '[JSON] CardSet
  :<|> "api" :> "card_sets" :> Capture "id" Int :> DeleteNoContent

cardSetServer :: Server CardSetAPI
cardSetServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, name, code, release_date, set_type, total_cards, description, logo_url FROM card_sets" :: IO [CardSet]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO card_sets (name, code, release_date, set_type, total_cards, description, logo_url) VALUES (?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, name, code, release_date, set_type, total_cards, description, logo_url FROM card_sets WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [CardSet]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, code, release_date, set_type, total_cards, description, logo_url FROM card_sets WHERE id = ?" (Only eid) :: IO [CardSet]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE card_sets SET name = ?, code = ?, release_date = ?, set_type = ?, total_cards = ?, description = ?, logo_url = ? WHERE id = ?" bodyRow
        query conn "SELECT id, name, code, release_date, set_type, total_cards, description, logo_url FROM card_sets WHERE id = ?" (Only eid) :: IO [CardSet]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM card_sets WHERE id = ?" (Only eid)
      return NoContent

