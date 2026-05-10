{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleService where

import CardsProject.Content.Types

-- Domain service stub for Article
validateArticle :: NewArticle -> Either String NewArticle
validateArticle body = Right body

