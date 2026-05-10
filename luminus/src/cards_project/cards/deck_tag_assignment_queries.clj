(ns cards_project.cards.deck-tag-assignment-queries
  (:require [hugsql.core :as hugsql]
            [cards_project.db]))   ; loads set-adapter! side effect

(hugsql/def-db-fns "sql/cards/deck_tag_assignment.sql")
