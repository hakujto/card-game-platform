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
import Data.Text (Text)

type ArticleCommentAPI
  =    "api" :> "article_comments" :> Get '[JSON] [ArticleComment]
  :<|> "api" :> "article_comments" :> ReqBody '[JSON] NewArticleComment :> PostCreated '[JSON] ArticleComment
  :<|> "api" :> "article_comments" :> Capture "id" Int :> Get '[JSON] ArticleComment
  :<|> "api" :> "article_comments" :> Capture "id" Int :> ReqBody '[JSON] NewArticleComment :> Put '[JSON] ArticleComment
  :<|> "api" :> "article_comments" :> Capture "id" Int :> ReqBody '[JSON] NewArticleComment :> Patch '[JSON] ArticleComment
  :<|> "api" :> "article_comments" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "article_comments" :> Capture "id" Int :> "hide" :> Post '[JSON] NoContent
  :<|> "api" :> "article_comments" :> Capture "id" Int :> "unhide" :> Post '[JSON] NoContent

articleCommentServer :: Server ArticleCommentAPI
articleCommentServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorHide
  :<|> behaviorUnhide
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

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE article_comments SET body = ?, is_hidden = ?, created_at = ?, article_id = ?, author_id = ?, parent_comment_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, body, is_hidden, created_at, article_id, author_id, parent_comment_id FROM article_comments WHERE id = ?" (Only eid) :: IO [ArticleComment]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

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
          liftIO $ ArticleCommentSvc.hide eid
          return NoContent

    behaviorUnhide eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, body, is_hidden, created_at, article_id, author_id, parent_comment_id FROM article_comments WHERE id = ?" (Only eid) :: IO [ArticleComment]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ ArticleCommentSvc.unhide eid
          return NoContent

