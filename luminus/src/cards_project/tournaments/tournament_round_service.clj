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
  (throw (ex-info "start not implemented" {:id id})))

(defn- complete-behavior! [id]
  (throw (ex-info "complete not implemented" {:id id})))

(defn- generate-pairings-behavior! [id]
  (throw (ex-info "generate_pairings not implemented" {:id id})))

(defn- is-time-expired-behavior! [id]
  (throw (ex-info "is_time_expired not implemented" {:id id})))

(defn start!
  [id]
  (if (queries/get-tournament-round-by-id db-spec {:id id})
    (start-behavior! id)
    (throw (ex-info "TournamentRound not found" {:id id}))))

(defn complete!
  [id]
  (if (queries/get-tournament-round-by-id db-spec {:id id})
    (complete-behavior! id)
    (throw (ex-info "TournamentRound not found" {:id id}))))

(defn generate-pairings!
  [id]
  (if (queries/get-tournament-round-by-id db-spec {:id id})
    (generate-pairings-behavior! id)
    (throw (ex-info "TournamentRound not found" {:id id}))))

