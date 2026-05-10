{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.DeckCardHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type DeckCardAPI
  =    "api" :> "deck_cards" :> Get '[JSON] [DeckCard]
  :<|> "api" :> "deck_cards" :> ReqBody '[JSON] NewDeckCard :> PostCreated '[JSON] DeckCard
  :<|> "api" :> "deck_cards" :> Capture "id" Int :> Get '[JSON] DeckCard
  :<|> "api" :> "deck_cards" :> Capture "id" Int :> ReqBody '[JSON] NewDeckCard :> Put '[JSON] DeckCard
  :<|> "api" :> "deck_cards" :> Capture "id" Int :> ReqBody '[JSON] NewDeckCard :> Patch '[JSON] DeckCard
  :<|> "api" :> "deck_cards" :> Capture "id" Int :> DeleteNoContent

deckCardServer :: Server DeckCardAPI
deckCardServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, quantity, is_commander, deck_id, card_id FROM deck_cards" :: IO [DeckCard]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO deck_cards (quantity, is_commander, deck_id, card_id) VALUES (?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, quantity, is_commander, deck_id, card_id FROM deck_cards WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [DeckCard]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, is_commander, deck_id, card_id FROM deck_cards WHERE id = ?" (Only eid) :: IO [DeckCard]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE deck_cards SET quantity = ?, is_commander = ?, deck_id = ?, card_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, quantity, is_commander, deck_id, card_id FROM deck_cards WHERE id = ?" (Only eid) :: IO [DeckCard]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM deck_cards WHERE id = ?" (Only eid)
      return NoContent

