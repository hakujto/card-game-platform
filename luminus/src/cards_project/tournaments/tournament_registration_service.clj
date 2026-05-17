(ns cards_project.tournaments.tournament-registration-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-registration-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-tournament-registration
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- withdraw-behavior! [id]
  (throw (ex-info "withdraw not implemented" {:id id})))

(defn- disqualify-behavior! [id reason]
  (throw (ex-info "disqualify not implemented" {:id id})))

(defn- promote-from-waitlist-behavior! [id]
  (throw (ex-info "promote_from_waitlist not implemented" {:id id})))

(defn withdraw!
  [id]
  (if (queries/get-tournament-registration-by-id db-spec {:id id})
    (withdraw-behavior! id)
    (throw (ex-info "TournamentRegistration not found" {:id id}))))

(defn disqualify!
  [id reason]
  (if (queries/get-tournament-registration-by-id db-spec {:id id})
    (disqualify-behavior! id reason)
    (throw (ex-info "TournamentRegistration not found" {:id id}))))

(defn promote-from-waitlist!
  [id]
  (if (queries/get-tournament-registration-by-id db-spec {:id id})
    (promote-from-waitlist-behavior! id)
    (throw (ex-info "TournamentRegistration not found" {:id id}))))

