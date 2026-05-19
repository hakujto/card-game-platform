(ns cards_project.tournaments.tournament-prize-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-prize-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-tournament-prize
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- applies-to-placement-behavior! [id placement]
  ; TODO: implement applies_to_placement
  nil)

(defn- award-to-player-behavior! [id player-id]
  ; TODO: implement award_to_player
  nil)

(defn applies-to-placement!
  [id placement]
  (if (queries/get-tournament-prize-by-id db-spec {:id id})
    (applies-to-placement-behavior! id placement)
    (throw (ex-info "TournamentPrize not found" {:id id}))))

(defn award-to-player!
  [id player-id]
  (if (queries/get-tournament-prize-by-id db-spec {:id id})
    (award-to-player-behavior! id player-id)
    (throw (ex-info "TournamentPrize not found" {:id id}))))

