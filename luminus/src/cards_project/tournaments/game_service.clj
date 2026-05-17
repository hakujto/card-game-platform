(ns cards_project.tournaments.game-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.game-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-game
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- record-winner-behavior! [id winner-side]
  (throw (ex-info "record_winner not implemented" {:id id})))

(defn- duration-minutes-behavior! [id]
  (throw (ex-info "duration_minutes not implemented" {:id id})))

(defn record-winner!
  [id winner-side]
  (if (queries/get-game-by-id db-spec {:id id})
    (record-winner-behavior! id winner-side)
    (throw (ex-info "Game not found" {:id id}))))

