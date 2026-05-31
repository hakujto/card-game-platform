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
  ; TODO: implement record_winner
  nil)

(defn- duration-minutes-behavior! [id]
  ; TODO: implement duration_minutes
  nil)

(defn record-winner!
  [id winner-side]
  (if-let [record (queries/get-game-by-id db-spec {:id id})]
    (record-winner-behavior! id winner-side)
    (throw (ex-info "Game not found" {:id id}))))

(defn duration-minutes!
  [id]
  (if-let [record (queries/get-game-by-id db-spec {:id id})]
    (duration-minutes-behavior! id)
    (throw (ex-info "Game not found" {:id id}))))

