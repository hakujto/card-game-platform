{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleTagService
  ( validateArticleTag, rename, article_count
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service stub for ArticleTag
validateArticleTag :: NewArticleTag -> Either String NewArticleTag
validateArticleTag body = Right body

-- @invoke behavior stub (no-op)
rename :: Int -> IO ()
rename _eid = return ()

-- @invoke behavior stub (no-op)
article_count :: Int -> IO Int
article_count _eid = return (error "TODO")

