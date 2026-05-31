(ns cards_project.tournaments.tournament-round-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-round-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-tournament-round
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- start-behavior! [id]
  ; TODO: implement start
  nil)

(defn- complete-behavior! [id]
  ; TODO: implement complete
  nil)

(defn- generate-pairings-behavior! [id]
  ; TODO: implement generate_pairings
  nil)

(defn- is-time-expired-behavior! [id]
  ; TODO: implement is_time_expired
  nil)

(defn start!
  [id]
  (if-let [record (queries/get-tournament-round-by-id db-spec {:id id})]
    (start-behavior! id)
    (throw (ex-info "TournamentRound not found" {:id id}))))

(defn complete!
  [id]
  (if-let [record (queries/get-tournament-round-by-id db-spec {:id id})]
    (complete-behavior! id)
    (throw (ex-info "TournamentRound not found" {:id id}))))

(defn generate-pairings!
  [id]
  (if-let [record (queries/get-tournament-round-by-id db-spec {:id id})]
    (generate-pairings-behavior! id)
    (throw (ex-info "TournamentRound not found" {:id id}))))

(defn is-time-expired!
  [id]
  (if-let [record (queries/get-tournament-round-by-id db-spec {:id id})]
    (is-time-expired-behavior! id)
    (throw (ex-info "TournamentRound not found" {:id id}))))

