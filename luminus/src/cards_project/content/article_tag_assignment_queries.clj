(ns cards_project.content.article-tag-assignment-queries
  (:require [hugsql.core :as hugsql]
            [cards_project.db]))   ; loads set-adapter! side effect

(hugsql/def-db-fns "sql/content/article_tag_assignment.sql")
