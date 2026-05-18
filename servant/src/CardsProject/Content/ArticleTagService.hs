{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleTagService
  ( validateArticleTag, rename, article_count
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for ArticleTag
validateArticleTag :: NewArticleTag -> Either String NewArticleTag
validateArticleTag body = Right body

-- @invoke behavior stub
rename :: Int -> IO ()
rename eid = do
  -- params: new_name: String -- extract from body in handler when implementing
  throwIO (userError "rename not implemented")

-- @invoke behavior stub
article_count :: Int -> IO Int
article_count eid = do
  throwIO (userError "article_count not implemented")

