{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleCommentService
  ( validateArticleComment, hide, unhide, is_reply
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for ArticleComment
validateArticleComment :: NewArticleComment -> Either String NewArticleComment
validateArticleComment body = Right body

-- @invoke behavior stub (no-op)
hide :: Int -> IO ()
hide _eid = throwIO (userError "hide not implemented")

-- @invoke behavior stub (no-op)
unhide :: Int -> IO ()
unhide _eid = throwIO (userError "unhide not implemented")

-- @invoke behavior stub (no-op)
is_reply :: Int -> IO Bool
is_reply _eid = throwIO (userError "is_reply not implemented")

