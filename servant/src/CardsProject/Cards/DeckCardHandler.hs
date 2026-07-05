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
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Cards.DeckCardService as DeckCardSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type DeckCardAPI
  =    "api" :> "deck_cards" :> Get '[JSON] [DeckCard]
  :<|> "api" :> "deck_cards" :> ReqBody '[JSON] NewDeckCard :> PostCreated '[JSON] DeckCard
  :<|> "api" :> "deck_cards" :> Capture "id" Int :> Get '[JSON] DeckCard
  :<|> "api" :> "deck_cards" :> Capture "id" Int :> ReqBody '[JSON] NewDeckCard :> Patch '[JSON] DeckCard
  :<|> "api" :> "deck_cards" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "deck_cards" :> Capture "id" Int :> "increment" :> ReqBody '[JSON] Object :> PatchNoContent
  :<|> "api" :> "deck_cards" :> Capture "id" Int :> "decrement" :> ReqBody '[JSON] Object :> PatchNoContent

deckCardServer :: Server DeckCardAPI
deckCardServer = listAll
  :<|> create
  :<|> getOne
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorIncrement
  :<|> behaviorDecrement
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, quantity, is_commander, deck_id, card_id FROM deck_cards" :: IO [DeckCard]

    create body = do
      case DeckCardSvc.validateDeckCard body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO deck_cards (quantity, is_commander, deck_id, card_id) VALUES (?, ?, ?, ?)" validBody
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

    partialUpdate eid body = do
      case DeckCardSvc.validateDeckCard body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = [toField (bDeckCardQuantity validBody), toField (bDeckCardIsCommander validBody), toField (bDeckCardDeckId validBody), toField (bDeckCardCardId validBody), toField eid]
            execute conn "UPDATE deck_cards SET quantity = ?, is_commander = ?, deck_id = ?, card_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, quantity, is_commander, deck_id, card_id FROM deck_cards WHERE id = ?" (Only eid) :: IO [DeckCard]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM deck_cards WHERE id = ?" (Only eid)
      return NoContent

    behaviorIncrement eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, is_commander, deck_id, card_id FROM deck_cards WHERE id = ?" (Only eid) :: IO [DeckCard]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckCardSvc.increment eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDecrement eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, is_commander, deck_id, card_id FROM deck_cards WHERE id = ?" (Only eid) :: IO [DeckCard]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckCardSvc.decrement eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

