{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleService
  ( validateArticle, publish, archive, increment_view, reading_time_minutes
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Article
validateArticle :: NewArticle -> Either String NewArticle
validateArticle body = Right body

-- @invoke behavior stub
publish :: Int -> IO ()
publish eid = do
  throwIO (userError "publish not implemented")

-- @invoke behavior stub
archive :: Int -> IO ()
archive eid = do
  throwIO (userError "archive not implemented")

-- @invoke behavior stub
increment_view :: Int -> IO ()
increment_view eid = do
  throwIO (userError "increment_view not implemented")

-- domain behavior stub
reading_time_minutes :: IO Int
reading_time_minutes  =
  throwIO (userError "reading_time_minutes not implemented")

