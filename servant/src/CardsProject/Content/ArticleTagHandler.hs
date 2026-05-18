{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Content.ArticleTagHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Content.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Content.ArticleTagService as ArticleTagSvc
import Data.Aeson (Object)
import Data.Text (Text)

type ArticleTagAPI
  =    "api" :> "article_tags" :> Get '[JSON] [ArticleTag]
  :<|> "api" :> "article_tags" :> ReqBody '[JSON] NewArticleTag :> PostCreated '[JSON] ArticleTag
  :<|> "api" :> "article_tags" :> Capture "id" Int :> Get '[JSON] ArticleTag
  :<|> "api" :> "article_tags" :> Capture "id" Int :> ReqBody '[JSON] NewArticleTag :> Put '[JSON] ArticleTag
  :<|> "api" :> "article_tags" :> Capture "id" Int :> ReqBody '[JSON] NewArticleTag :> Patch '[JSON] ArticleTag
  :<|> "api" :> "article_tags" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "article_tags" :> Capture "id" Int :> "rename" :> ReqBody '[JSON] Object :> Patch '[JSON] NoContent
  :<|> "api" :> "article_tags" :> Capture "id" Int :> "article-count" :> Get '[JSON] Int

articleTagServer :: Server ArticleTagAPI
articleTagServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorRename
  :<|> behaviorArticleCount
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, name, slug FROM article_tags" :: IO [ArticleTag]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO article_tags (name, slug) VALUES (?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, name, slug FROM article_tags WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [ArticleTag]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, slug FROM article_tags WHERE id = ?" (Only eid) :: IO [ArticleTag]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE article_tags SET name = ?, slug = ? WHERE id = ?" bodyRow
        query conn "SELECT id, name, slug FROM article_tags WHERE id = ?" (Only eid) :: IO [ArticleTag]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM article_tags WHERE id = ?" (Only eid)
      return NoContent

    behaviorRename eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, slug FROM article_tags WHERE id = ?" (Only eid) :: IO [ArticleTag]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ ArticleTagSvc.rename eid
          return NoContent

    behaviorArticleCount eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, slug FROM article_tags WHERE id = ?" (Only eid) :: IO [ArticleTag]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ ArticleTagSvc.article_count eid
          return result

