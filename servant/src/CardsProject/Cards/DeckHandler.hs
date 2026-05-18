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
import qualified CardsProject.Cards.DeckService as DeckSvc
import Data.Aeson (Object)
import Data.Text (Text)

type DeckAPI
  =    "api" :> "decks" :> Get '[JSON] [Deck]
  :<|> "api" :> "decks" :> ReqBody '[JSON] NewDeck :> PostCreated '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> Get '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> ReqBody '[JSON] NewDeck :> Put '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> ReqBody '[JSON] NewDeck :> Patch '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "decks" :> Capture "id" Int :> "validate" :> Get '[JSON] Bool
  :<|> "api" :> "decks" :> Capture "id" Int :> "cards" :> ReqBody '[JSON] Object :> Post '[JSON] NoContent
  :<|> "api" :> "decks" :> Capture "id" Int :> "cards" :> Capture "card_id" Int :> DeleteNoContent
  :<|> "api" :> "decks" :> Capture "id" Int :> "win-rate" :> Get '[JSON] Text
  :<|> "api" :> "decks" :> Capture "id" Int :> "clone" :> Post '[JSON] Text
  :<|> "api" :> "decks" :> Capture "id" Int :> "publish" :> Post '[JSON] NoContent
  :<|> "api" :> "decks" :> Capture "id" Int :> "unpublish" :> Post '[JSON] NoContent
  :<|> "api" :> "decks" :> Capture "id" Int :> "certify" :> Post '[JSON] Bool

deckServer :: Server DeckAPI
deckServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorValidateSize
  :<|> behaviorAddCard
  :<|> behaviorRemoveCard
  :<|> behaviorWinRate
  :<|> behaviorClone
  :<|> behaviorPublish
  :<|> behaviorUnpublish
  :<|> behaviorCertifyTournamentLegal
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks" :: IO [Deck]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO decks (name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Deck]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE decks SET name = ?, description = ?, format = ?, is_public = ?, is_tournament_legal = ?, archetype = ?, wins = ?, losses = ?, draws = ?, created_at = ?, updated_at = ?, player_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM decks WHERE id = ?" (Only eid)
      return NoContent

    behaviorValidateSize eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ DeckSvc.validate_size eid
          return result

    behaviorAddCard eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ DeckSvc.add_card eid
          return NoContent

    behaviorRemoveCard eid _cardId = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ DeckSvc.remove_card eid
          return NoContent

    behaviorWinRate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ DeckSvc.win_rate eid
          return result

    behaviorClone eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ DeckSvc.clone eid
          return result

    behaviorPublish eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ DeckSvc.publish eid
          return NoContent

    behaviorUnpublish eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ DeckSvc.unpublish eid
          return NoContent

    behaviorCertifyTournamentLegal eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ DeckSvc.certify_tournament_legal eid
          return result

