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
import qualified CardsProject.Cards.DeckSideboardCardService as DeckSideboardCardSvc
import Data.Aeson (Object)
import Data.Text (Text)

type DeckSideboardCardAPI
  =    "api" :> "deck_sideboard_cards" :> Get '[JSON] [DeckSideboardCard]
  :<|> "api" :> "deck_sideboard_cards" :> ReqBody '[JSON] NewDeckSideboardCard :> PostCreated '[JSON] DeckSideboardCard
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> Get '[JSON] DeckSideboardCard
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> ReqBody '[JSON] NewDeckSideboardCard :> Put '[JSON] DeckSideboardCard
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> ReqBody '[JSON] NewDeckSideboardCard :> Patch '[JSON] DeckSideboardCard
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> "increment" :> ReqBody '[JSON] Object :> Patch '[JSON] NoContent
  :<|> "api" :> "deck_sideboard_cards" :> Capture "id" Int :> "decrement" :> ReqBody '[JSON] Object :> Patch '[JSON] NoContent

deckSideboardCardServer :: Server DeckSideboardCardAPI
deckSideboardCardServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorIncrement
  :<|> behaviorDecrement
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, quantity, deck_id, card_id FROM deck_sideboard_cards" :: IO [DeckSideboardCard]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO deck_sideboard_cards (quantity, deck_id, card_id) VALUES (?, ?, ?)" body
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

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE deck_sideboard_cards SET quantity = ?, deck_id = ?, card_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, quantity, deck_id, card_id FROM deck_sideboard_cards WHERE id = ?" (Only eid) :: IO [DeckSideboardCard]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

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
          liftIO $ DeckSideboardCardSvc.increment eid
          return NoContent

    behaviorDecrement eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, deck_id, card_id FROM deck_sideboard_cards WHERE id = ?" (Only eid) :: IO [DeckSideboardCard]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ DeckSideboardCardSvc.decrement eid
          return NoContent

