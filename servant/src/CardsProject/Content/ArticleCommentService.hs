{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleCommentService where

import CardsProject.Content.Types

-- Domain service stub for ArticleComment
validateArticleComment :: NewArticleComment -> Either String NewArticleComment
validateArticleComment body = Right body

