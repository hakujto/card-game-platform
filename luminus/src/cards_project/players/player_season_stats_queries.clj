(ns cards_project.players.player-season-stats-queries
  (:require [hugsql.core :as hugsql]
            [cards_project.db]))   ; loads set-adapter! side effect

(hugsql/def-db-fns "sql/players/player_season_stats.sql")
