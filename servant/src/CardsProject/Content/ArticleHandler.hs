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
import qualified Data.ByteString.Lazy.Char8
import Data.Text (Text)
import Control.Exception (catch, IOException)
import Data.Text (Text)

type ArticleAPI
  =    "api" :> "articles" :> QueryParam "q" Text :> Get '[JSON] [Article]
  :<|> "api" :> "articles" :> ReqBody '[JSON] NewArticle :> PostCreated '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> Get '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> ReqBody '[JSON] NewArticle :> Put '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> ReqBody '[JSON] NewArticle :> Patch '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> "publish" :> PostNoContent
  :<|> "api" :> "articles" :> Capture "id" Int :> "archive" :> PostNoContent
  :<|> "api" :> "articles" :> Capture "id" Int :> "view" :> PostNoContent
  :<|> "api" :> "articles" :> Capture "id" Int :> "like" :> PostNoContent
  :<|> "api" :> "articles" :> Capture "id" Int :> "like" :> DeleteNoContent
  :<|> "api" :> "articles" :> Capture "id" Int :> "reading-time" :> Get '[JSON] Int
  :<|> "api" :> "articles" :> Capture "id" Int :> "transitions" :> "draft-to-published" :> Patch '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> "transitions" :> "published-to-archived" :> Patch '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> "transitions" :> "archived-to-draft" :> Patch '[JSON] Article
  :<|> "api" :> "articles" :> Capture "id" Int :> "transitions" :> "published-to-draft" :> Patch '[JSON] Article

articleServer :: Server ArticleAPI
articleServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> behaviorPublish
  :<|> behaviorArchive
  :<|> behaviorIncrementView
  :<|> behaviorLike
  :<|> behaviorUnlike
  :<|> behaviorReadingTimeMinutes
  :<|> transitionHandlerDraftToPublished
  :<|> transitionHandlerPublishedToArchived
  :<|> transitionHandlerArchivedToDraft
  :<|> transitionHandlerPublishedToDraft
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles" :: IO [Article]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles WHERE title LIKE ? OR excerpt LIKE ?" ((qp, qp)) :: IO [Article]

    create body = do
      case ArticleSvc.validateArticle body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO articles (title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Article]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      case ArticleSvc.validateArticle body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = toRow validBody ++ toRow (Only eid)
            execute conn "UPDATE articles SET title = ?, slug = ?, body = ?, excerpt = ?, cover_image_url = ?, status = ?, article_type = ?, language = ?, view_count = ?, likes_count = ?, is_featured = ?, published_at = ?, created_at = ?, updated_at = ?, author_id = ?, featured_deck_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    behaviorPublish eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ArticleSvc.publish eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorArchive eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ArticleSvc.archive eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorIncrementView eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ArticleSvc.increment_view eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorLike eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ArticleSvc.like eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorUnlike eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ArticleSvc.unlike eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorReadingTimeMinutes eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ArticleSvc.reading_time_minutes eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    transitionHandlerDraftToPublished eid = do
      result <- liftIO $ (ArticleSvc.transitionDraftToPublished eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerPublishedToArchived eid = do
      result <- liftIO $ (ArticleSvc.transitionPublishedToArchived eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerArchivedToDraft eid = do
      result <- liftIO $ (ArticleSvc.transitionArchivedToDraft eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerPublishedToDraft eid = do
      result <- liftIO $ (ArticleSvc.transitionPublishedToDraft eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

