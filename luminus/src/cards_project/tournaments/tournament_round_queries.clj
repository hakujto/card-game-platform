(ns cards_project.tournaments.tournament-round-queries
  (:require [hugsql.core :as hugsql]
            [cards_project.db]))   ; loads set-adapter! side effect

(hugsql/def-db-fns "sql/tournaments/tournament_round.sql")
