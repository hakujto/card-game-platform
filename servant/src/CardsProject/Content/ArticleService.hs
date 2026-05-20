{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleService
  ( validateArticle, publish, archive, increment_view, like, unlike, reading_time_minutes, enumToText, assertTransition, allowedTransitions, transitionDraftToPublished, transitionPublishedToArchived, transitionArchivedToDraft, transitionPublishedToDraft
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import qualified Data.Text
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for Article
validateArticle :: NewArticle -> Either String NewArticle
validateArticle body = Right body

-- @invoke behavior stub (no-op)
publish :: Int -> IO ()
publish _eid = return ()

-- @invoke behavior stub (no-op)
archive :: Int -> IO ()
archive _eid = return ()

-- @invoke behavior stub (no-op)
increment_view :: Int -> IO ()
increment_view _eid = return ()

-- @invoke behavior stub (no-op)
like :: Int -> IO ()
like _eid = return ()

-- @invoke behavior stub (no-op)
unlike :: Int -> IO ()
unlike _eid = return ()

-- @invoke behavior stub (no-op)
reading_time_minutes :: Int -> IO Int
reading_time_minutes _eid = return (error "TODO")

-- ── Lifecycle state machine ─────────────────────────────────────────
allowedTransitions :: [(Text, [Text])]
allowedTransitions =
  [   ("Draft", ["Published"])
  ,  ("Published", ["Archived"])
  ,  ("Archived", ["Draft"])
  ]

-- Convert status enum to Text: FooStatusType_Active -> "Active"
enumToText :: Show a => a -> Text
enumToText v = Data.Text.pack $ drop 1 $ dropWhile (/= '_') (show v)

assertTransition :: Text -> Text -> IO ()
assertTransition current to_ = do
  let allowed = maybe [] id (lookup current allowedTransitions)
  if to_ `elem` allowed
    then return ()
    else throwIO (userError $ "Transition " ++ show current ++ " -> " ++ show to_ ++ " not allowed")

transitionDraftToPublished :: Int -> IO Article
transitionDraftToPublished eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
  case rows of
    [] -> throwIO (userError "Article not found")
    (record:_) -> do
      assertTransition (enumToText (articleStatus record)) "Published"
      execute conn "UPDATE articles SET status = ? WHERE id = ?" ("Published" :: Text, eid)
      publish eid  -- @after
      updated <- query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Article not found after update")

transitionPublishedToArchived :: Int -> IO Article
transitionPublishedToArchived eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
  case rows of
    [] -> throwIO (userError "Article not found")
    (record:_) -> do
      assertTransition (enumToText (articleStatus record)) "Archived"
      execute conn "UPDATE articles SET status = ? WHERE id = ?" ("Archived" :: Text, eid)
      archive eid  -- @after
      updated <- query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Article not found after update")

transitionArchivedToDraft :: Int -> IO Article
transitionArchivedToDraft eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
  case rows of
    [] -> throwIO (userError "Article not found")
    (record:_) -> do
      assertTransition (enumToText (articleStatus record)) "Draft"
      execute conn "UPDATE articles SET status = ? WHERE id = ?" ("Draft" :: Text, eid)
      updated <- query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
      case updated of
        (r:_) -> return r
        []    -> throwIO (userError "Article not found after update")

transitionPublishedToDraft :: Int -> IO Article
transitionPublishedToDraft eid = withDb $ \conn -> do
  rows <- query conn "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, created_at, updated_at, author_id, featured_deck_id, comments_id FROM articles WHERE id = ?" (Only eid) :: IO [Article]
  case rows of
    [] -> throwIO (userError "Article not found")
    (record:_) -> do
      throwIO (userError "Transition Published -> Draft is not allowed")

