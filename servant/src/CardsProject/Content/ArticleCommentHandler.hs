{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Content.ArticleCommentHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Content.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Content.ArticleCommentService as ArticleCommentSvc
import Control.Exception (catch, IOException)
import Data.Text (Text)

type ArticleCommentAPI
  =    "api" :> "article_comments" :> Get '[JSON] [ArticleComment]
  :<|> "api" :> "article_comments" :> ReqBody '[JSON] NewArticleComment :> PostCreated '[JSON] ArticleComment
  :<|> "api" :> "article_comments" :> Capture "id" Int :> Get '[JSON] ArticleComment
  :<|> "api" :> "article_comments" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "article_comments" :> Capture "id" Int :> "hide" :> PostNoContent
  :<|> "api" :> "article_comments" :> Capture "id" Int :> "unhide" :> PostNoContent
  :<|> "api" :> "article_comments" :> Capture "id" Int :> "is-reply" :> Get '[JSON] Bool

articleCommentServer :: Server ArticleCommentAPI
articleCommentServer = listAll
  :<|> create
  :<|> getOne
  :<|> delete
  :<|> behaviorHide
  :<|> behaviorUnhide
  :<|> behaviorIsReply
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, body, is_hidden, created_at, article_id, author_id, parent_comment_id FROM article_comments" :: IO [ArticleComment]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO article_comments (body, is_hidden, created_at, article_id, author_id, parent_comment_id) VALUES (?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, body, is_hidden, created_at, article_id, author_id, parent_comment_id FROM article_comments WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [ArticleComment]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, body, is_hidden, created_at, article_id, author_id, parent_comment_id FROM article_comments WHERE id = ?" (Only eid) :: IO [ArticleComment]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM article_comments WHERE id = ?" (Only eid)
      return NoContent

    behaviorHide eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, body, is_hidden, created_at, article_id, author_id, parent_comment_id FROM article_comments WHERE id = ?" (Only eid) :: IO [ArticleComment]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ArticleCommentSvc.hide eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorUnhide eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, body, is_hidden, created_at, article_id, author_id, parent_comment_id FROM article_comments WHERE id = ?" (Only eid) :: IO [ArticleComment]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ArticleCommentSvc.unhide eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorIsReply eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, body, is_hidden, created_at, article_id, author_id, parent_comment_id FROM article_comments WHERE id = ?" (Only eid) :: IO [ArticleComment]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> ArticleCommentSvc.is_reply eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

