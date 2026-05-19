(ns cards_project.players.player-season-stats-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-season-stats-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-player-season-stats
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- win-rate-behavior! [id]
  ; TODO: implement win_rate
  nil)

(defn- add-points-behavior! [id points]
  ; TODO: implement add_points
  nil)

(defn- record-tournament-win-behavior! [id]
  ; TODO: implement record_tournament_win
  nil)

(defn win-rate!
  [id]
  (if (queries/get-player-season-stats-by-id db-spec {:id id})
    (win-rate-behavior! id)
    (throw (ex-info "PlayerSeasonStats not found" {:id id}))))

(defn add-points!
  [id points]
  (if (queries/get-player-season-stats-by-id db-spec {:id id})
    (add-points-behavior! id points)
    (throw (ex-info "PlayerSeasonStats not found" {:id id}))))

(defn record-tournament-win!
  [id]
  (if (queries/get-player-season-stats-by-id db-spec {:id id})
    (record-tournament-win-behavior! id)
    (throw (ex-info "PlayerSeasonStats not found" {:id id}))))

