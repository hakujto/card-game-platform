(ns cards_project.tournaments.tournament-judge-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-judge-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-tournament-judge
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- promote-to-head-behavior! [id]
  (throw (ex-info "promote_to_head not implemented" {:id id})))

(defn- remove-behavior! [id]
  (throw (ex-info "remove not implemented" {:id id})))

(defn promote-to-head!
  [id]
  (if (queries/get-tournament-judge-by-id db-spec {:id id})
    (promote-to-head-behavior! id)
    (throw (ex-info "TournamentJudge not found" {:id id}))))

(defn remove!
  [id]
  (if (queries/get-tournament-judge-by-id db-spec {:id id})
    (remove-behavior! id)
    (throw (ex-info "TournamentJudge not found" {:id id}))))

