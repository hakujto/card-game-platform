{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.DeckHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type DeckAPI
  =    "api" :> "decks" :> Get '[JSON] [Deck]
  :<|> "api" :> "decks" :> ReqBody '[JSON] NewDeck :> PostCreated '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> Get '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> ReqBody '[JSON] NewDeck :> Put '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> ReqBody '[JSON] NewDeck :> Patch '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> DeleteNoContent

deckServer :: Server DeckAPI
deckServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, created_at, updated_at, player_id FROM decks" :: IO [Deck]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO decks (name, description, format, is_public, is_tournament_legal, archetype, wins, losses, created_at, updated_at, player_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Deck]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE decks SET name = ?, description = ?, format = ?, is_public = ?, is_tournament_legal = ?, archetype = ?, wins = ?, losses = ?, created_at = ?, updated_at = ?, player_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM decks WHERE id = ?" (Only eid)
      return NoContent

