{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleTagAssignmentService where

import CardsProject.Content.Types

-- Domain service stub for ArticleTagAssignment
validateArticleTagAssignment :: NewArticleTagAssignment -> Either String NewArticleTagAssignment
validateArticleTagAssignment body = Right body

