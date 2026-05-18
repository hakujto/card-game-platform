{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Content.ArticleHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Content.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Content.ArticleService as ArticleSvc
import Data.Text (Text)

type ArticleAPI
  =    "api" :> "articles" :> Get '[JSON] [Article]
  :<|> "api" :> "articles" :> ReqBody '[JSON] NewArticle :> PostCreated '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> Get '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> ReqBody '[JSON] NewArticle :> Put '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> ReqBody '[JSON] NewArticle :> Patch '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "articles" :> Capture "id" Int :> "publish" :> Post '[JSON] NoContent
  :<|> "api" :> "articles" :> Capture "id" Int :> "archive" :> Post '[JSON] NoContent
  :<|> "api" :> "articles" :> Capture "id" Int :> "view" :> Post '[JSON] NoContent
  :<|> "api" :> "articles" :> Capture "id" Int :> "reading-time" :> Get '[JSON] Int

articleServer :: Server ArticleAPI
articleServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorPublish
  :<|> behaviorArchive
  :<|> behaviorIncrementView
  :<|> behaviorReadingTimeMinutes
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, view_count, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles" :: IO [Article]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO articles (title, slug, body, excerpt, cover_image_url, status, article_type, view_count, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, view_count, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Article]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, view_count, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE articles SET title = ?, slug = ?, body = ?, excerpt = ?, cover_image_url = ?, status = ?, article_type = ?, view_count = ?, published_at = ?, created_at = ?, updated_at = ?, author_id = ?, featured_deck_id = ?, comments_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, view_count, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM articles WHERE id = ?" (Only eid)
      return NoContent

    behaviorPublish eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, view_count, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ ArticleSvc.publish eid
          return NoContent

    behaviorArchive eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, view_count, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ ArticleSvc.archive eid
          return NoContent

    behaviorIncrementView eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, view_count, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ ArticleSvc.increment_view eid
          return NoContent

    behaviorReadingTimeMinutes eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, view_count, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ ArticleSvc.reading_time_minutes eid
          return result

