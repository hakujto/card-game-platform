{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.DeckTagHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Cards.DeckTagService as DeckTagSvc
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type DeckTagAPI
  =    "api" :> "deck_tags" :> QueryParam "q" Text :> Get '[JSON] [DeckTag]
  :<|> "api" :> "deck_tags" :> ReqBody '[JSON] NewDeckTag :> PostCreated '[JSON] DeckTag
  :<|> "api" :> "deck_tags" :> Capture "id" Int :> Get '[JSON] DeckTag
  :<|> "api" :> "deck_tags" :> Capture "id" Int :> ReqBody '[JSON] NewDeckTag :> Patch '[JSON] DeckTag
  :<|> "api" :> "deck_tags" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "deck_tags" :> Capture "id" Int :> "rename" :> ReqBody '[JSON] Object :> PatchNoContent
  :<|> "api" :> "deck_tags" :> Capture "id" Int :> "merge" :> ReqBody '[JSON] Object :> PostNoContent

deckTagServer :: Server DeckTagAPI
deckTagServer = listAll
  :<|> create
  :<|> getOne
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorRename
  :<|> behaviorMergeInto
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, name, color FROM deck_tags" :: IO [DeckTag]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, name, color FROM deck_tags WHERE name LIKE ?" (Only qp) :: IO [DeckTag]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO deck_tags (name, color) VALUES (?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, name, color FROM deck_tags WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [DeckTag]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, color FROM deck_tags WHERE id = ?" (Only eid) :: IO [DeckTag]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE deck_tags SET name = ?, color = ? WHERE id = ?" bodyRow
        query conn "SELECT id, name, color FROM deck_tags WHERE id = ?" (Only eid) :: IO [DeckTag]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM deck_tags WHERE id = ?" (Only eid)
      return NoContent

    behaviorRename eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, color FROM deck_tags WHERE id = ?" (Only eid) :: IO [DeckTag]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckTagSvc.rename eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorMergeInto eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, color FROM deck_tags WHERE id = ?" (Only eid) :: IO [DeckTag]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DeckTagSvc.merge_into eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

