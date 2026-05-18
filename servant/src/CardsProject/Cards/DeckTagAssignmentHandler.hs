{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.DeckTagAssignmentHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type DeckTagAssignmentAPI
  =    "api" :> "deck_tag_assignments" :> Get '[JSON] [DeckTagAssignment]
  :<|> "api" :> "deck_tag_assignments" :> ReqBody '[JSON] NewDeckTagAssignment :> PostCreated '[JSON] DeckTagAssignment
  :<|> "api" :> "deck_tag_assignments" :> Capture "id" Int :> Get '[JSON] DeckTagAssignment
  :<|> "api" :> "deck_tag_assignments" :> Capture "id" Int :> ReqBody '[JSON] NewDeckTagAssignment :> Put '[JSON] DeckTagAssignment
  :<|> "api" :> "deck_tag_assignments" :> Capture "id" Int :> ReqBody '[JSON] NewDeckTagAssignment :> Patch '[JSON] DeckTagAssignment
  :<|> "api" :> "deck_tag_assignments" :> Capture "id" Int :> DeleteNoContent

deckTagAssignmentServer :: Server DeckTagAssignmentAPI
deckTagAssignmentServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, deck_id, tag_id FROM deck_tag_assignments" :: IO [DeckTagAssignment]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO deck_tag_assignments (deck_id, tag_id) VALUES (?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, deck_id, tag_id FROM deck_tag_assignments WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [DeckTagAssignment]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, deck_id, tag_id FROM deck_tag_assignments WHERE id = ?" (Only eid) :: IO [DeckTagAssignment]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE deck_tag_assignments SET deck_id = ?, tag_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, deck_id, tag_id FROM deck_tag_assignments WHERE id = ?" (Only eid) :: IO [DeckTagAssignment]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM deck_tag_assignments WHERE id = ?" (Only eid)
      return NoContent

