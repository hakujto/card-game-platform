{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Content.ArticleTagAssignmentHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Content.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type ArticleTagAssignmentAPI
  =    "api" :> "article_tag_assignments" :> Get '[JSON] [ArticleTagAssignment]
  :<|> "api" :> "article_tag_assignments" :> ReqBody '[JSON] NewArticleTagAssignment :> PostCreated '[JSON] ArticleTagAssignment
  :<|> "api" :> "article_tag_assignments" :> Capture "id" Int :> Get '[JSON] ArticleTagAssignment
  :<|> "api" :> "article_tag_assignments" :> Capture "id" Int :> ReqBody '[JSON] NewArticleTagAssignment :> Put '[JSON] ArticleTagAssignment
  :<|> "api" :> "article_tag_assignments" :> Capture "id" Int :> ReqBody '[JSON] NewArticleTagAssignment :> Patch '[JSON] ArticleTagAssignment
  :<|> "api" :> "article_tag_assignments" :> Capture "id" Int :> DeleteNoContent

articleTagAssignmentServer :: Server ArticleTagAssignmentAPI
articleTagAssignmentServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, article_id, tag_id FROM article_tag_assignments" :: IO [ArticleTagAssignment]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO article_tag_assignments (article_id, tag_id) VALUES (?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, article_id, tag_id FROM article_tag_assignments WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [ArticleTagAssignment]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, article_id, tag_id FROM article_tag_assignments WHERE id = ?" (Only eid) :: IO [ArticleTagAssignment]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE article_tag_assignments SET article_id = ?, tag_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, article_id, tag_id FROM article_tag_assignments WHERE id = ?" (Only eid) :: IO [ArticleTagAssignment]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM article_tag_assignments WHERE id = ?" (Only eid)
      return NoContent

