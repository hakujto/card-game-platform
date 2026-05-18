{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleTagService
  ( validateArticleTag, rename, article_count
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for ArticleTag
validateArticleTag :: NewArticleTag -> Either String NewArticleTag
validateArticleTag body = Right body

-- domain behavior stub
rename :: Text -> IO ()
rename _newName =
  throwIO (userError "rename not implemented")

-- domain behavior stub
article_count :: IO Int
article_count  =
  throwIO (userError "article_count not implemented")

