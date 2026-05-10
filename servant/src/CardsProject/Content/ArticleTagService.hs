{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleTagService where

import CardsProject.Content.Types

-- Domain service stub for ArticleTag
validateArticleTag :: NewArticleTag -> Either String NewArticleTag
validateArticleTag body = Right body

