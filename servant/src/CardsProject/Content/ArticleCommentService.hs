{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleCommentService
  ( validateArticleComment, hide, unhide, is_reply
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for ArticleComment
validateArticleComment :: NewArticleComment -> Either String NewArticleComment
validateArticleComment body = Right body

-- @invoke behavior stub
hide :: Int -> IO ()
hide eid = do
  throwIO (userError "hide not implemented")

-- @invoke behavior stub
unhide :: Int -> IO ()
unhide eid = do
  throwIO (userError "unhide not implemented")

-- @invoke behavior stub
is_reply :: Int -> IO Bool
is_reply eid = do
  throwIO (userError "is_reply not implemented")

