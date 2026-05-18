(ns cards_project.tournaments.match-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.match-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-match
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- record-result-behavior! [id p1-wins p2-wins]
  (throw (ex-info "record_result not implemented" {:id id})))

(defn- determine-winner-behavior! [id]
  (throw (ex-info "determine_winner not implemented" {:id id})))

(defn- concede-behavior! [id player-id]
  (throw (ex-info "concede not implemented" {:id id})))

(defn- draw-behavior! [id]
  (throw (ex-info "draw not implemented" {:id id})))

(defn record-result!
  [id p1-wins p2-wins]
  (if (queries/get-match-by-id db-spec {:id id})
    (do
      (record-result-behavior! id p1-wins p2-wins)
      (determine-winner-behavior! id))
    (throw (ex-info "Match not found" {:id id}))))

(defn determine-winner!
  [id]
  (if (queries/get-match-by-id db-spec {:id id})
    (determine-winner-behavior! id)
    (throw (ex-info "Match not found" {:id id}))))

(defn concede!
  [id player-id]
  (if (queries/get-match-by-id db-spec {:id id})
    (concede-behavior! id player-id)
    (throw (ex-info "Match not found" {:id id}))))

(defn draw!
  [id]
  (if (queries/get-match-by-id db-spec {:id id})
    (draw-behavior! id)
    (throw (ex-info "Match not found" {:id id}))))

