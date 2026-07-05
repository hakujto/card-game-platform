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
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Cards.DeckService as DeckSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type DeckAPI
  =    "api" :> "decks" :> QueryParam "q" Text :> Get '[JSON] [Deck]
  :<|> "api" :> "decks" :> ReqBody '[JSON] NewDeck :> PostCreated '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> Get '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> ReqBody '[JSON] NewDeck :> Put '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> ReqBody '[JSON] NewDeck :> Patch '[JSON] Deck
  :<|> "api" :> "decks" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "decks" :> Capture "id" Int :> "validate" :> Get '[JSON] Bool
  :<|> "api" :> "decks" :> Capture "id" Int :> "cards" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "decks" :> Capture "id" Int :> "cards" :> Capture "card_id" Int :> DeleteNoContent
  :<|> "api" :> "decks" :> Capture "id" Int :> "win-rate" :> Get '[JSON] Text
  :<|> "api" :> "decks" :> Capture "id" Int :> "clone" :> Post '[JSON] Text
  :<|> "api" :> "decks" :> Capture "id" Int :> "publish" :> PostNoContent
  :<|> "api" :> "decks" :> Capture "id" Int :> "unpublish" :> PostNoContent
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
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks" :: IO [Deck]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE name LIKE ? OR description LIKE ?" ((qp, qp)) :: IO [Deck]

    create body = do
      case DeckSvc.validateDeck body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO decks (name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
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
      case DeckSvc.validateDeck body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = [toField (bDeckName validBody), toField (bDeckDescription validBody), toField (bDeckFormat validBody), toField (bDeckIsPublic validBody), toField (bDeckIsTournamentLegal validBody), toField (bDeckArchetype validBody), toField (bDeckUpdatedAt validBody), toField (bDeckPlayerId validBody), toField eid]
            execute conn "UPDATE decks SET name = ?, description = ?, format = ?, is_public = ?, is_tournament_legal = ?, archetype = ?, updated_at = ?, player_id = ? WHERE id = ?" bodyRow
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
          eResult <- liftIO $ (Right <$> DeckSvc.validate_size eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorAddCard eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckSvc.add_card eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorRemoveCard eid _cardId = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckSvc.remove_card eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorWinRate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckSvc.win_rate eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorClone eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckSvc.clone eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorPublish eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckSvc.publish eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorUnpublish eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckSvc.unpublish eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorCertifyTournamentLegal eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, created_at, updated_at, player_id FROM decks WHERE id = ?" (Only eid) :: IO [Deck]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckSvc.certify_tournament_legal eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

