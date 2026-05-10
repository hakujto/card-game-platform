(ns cards_project.players.player-collection-queries
  (:require [hugsql.core :as hugsql]
            [cards_project.db]))   ; loads set-adapter! side effect

(hugsql/def-db-fns "sql/players/player_collection.sql")
