{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleTagAssignmentService
  ( validateArticleTagAssignment
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)

-- Domain service stub for ArticleTagAssignment
validateArticleTagAssignment :: NewArticleTagAssignment -> Either String NewArticleTagAssignment
validateArticleTagAssignment body = Right body

