{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.DeckSideboardCardHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Cards.DeckSideboardCardService as DeckSideboardCardSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type DeckSideboardCardAPI
  =    "api" :> "deck_sideboard_cards" :> Get '[JSON] [DeckSideboardCard]
  :<|> "api" :> "deck_sideboard_cards" :> ReqBody '[JSON] NewDeckSideboardCard :> PostCreated '[JSON] DeckSideboardCard
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> Get '[JSON] DeckSideboardCard
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> ReqBody '[JSON] NewDeckSideboardCard :> Patch '[JSON] DeckSideboardCard
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> "increment" :> ReqBody '[JSON] Object :> PatchNoContent
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> "decrement" :> ReqBody '[JSON] Object :> PatchNoContent

deckSideboardCardServer :: Server DeckSideboardCardAPI
deckSideboardCardServer = listAll
  :<|> create
  :<|> getOne
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorIncrement
  :<|> behaviorDecrement
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, quantity, deck_id, card_id FROM deck_sideboard_cards" :: IO [DeckSideboardCard]

    create body = do
      case DeckSideboardCardSvc.validateDeckSideboardCard body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO deck_sideboard_cards (quantity, deck_id, card_id) VALUES (?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, quantity, deck_id, card_id FROM deck_sideboard_cards WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [DeckSideboardCard]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, deck_id, card_id FROM deck_sideboard_cards WHERE id = ?" (Only eid) :: IO [DeckSideboardCard]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate eid body = do
      case DeckSideboardCardSvc.validateDeckSideboardCard body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = [toField (bDeckSideboardCardQuantity validBody), toField (bDeckSideboardCardDeckId validBody), toField (bDeckSideboardCardCardId validBody), toField eid]
            execute conn "UPDATE deck_sideboard_cards SET quantity = ?, deck_id = ?, card_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, quantity, deck_id, card_id FROM deck_sideboard_cards WHERE id = ?" (Only eid) :: IO [DeckSideboardCard]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM deck_sideboard_cards WHERE id = ?" (Only eid)
      return NoContent

    behaviorIncrement eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, deck_id, card_id FROM deck_sideboard_cards WHERE id = ?" (Only eid) :: IO [DeckSideboardCard]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckSideboardCardSvc.increment eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDecrement eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, deck_id, card_id FROM deck_sideboard_cards WHERE id = ?" (Only eid) :: IO [DeckSideboardCard]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckSideboardCardSvc.decrement eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

