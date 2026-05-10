(ns cards_project.tournaments.game-queries
  (:require [hugsql.core :as hugsql]
            [cards_project.db]))   ; loads set-adapter! side effect

(hugsql/def-db-fns "sql/tournaments/game.sql")
