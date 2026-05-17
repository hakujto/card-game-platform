(ns cards_project.tournaments.season-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.season-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-season
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- activate-behavior! [id]
  (throw (ex-info "activate not implemented" {:id id})))

(defn- deactivate-behavior! [id]
  (throw (ex-info "deactivate not implemented" {:id id})))

(defn- finalize-rewards-behavior! [id]
  (throw (ex-info "finalize_rewards not implemented" {:id id})))

(defn- is-ongoing-behavior! [id]
  (throw (ex-info "is_ongoing not implemented" {:id id})))

(defn activate!
  [id]
  (if (queries/get-season-by-id db-spec {:id id})
    (activate-behavior! id)
    (throw (ex-info "Season not found" {:id id}))))

(defn deactivate!
  [id]
  (if (queries/get-season-by-id db-spec {:id id})
    (deactivate-behavior! id)
    (throw (ex-info "Season not found" {:id id}))))

(defn finalize-rewards!
  [id]
  (if (queries/get-season-by-id db-spec {:id id})
    (finalize-rewards-behavior! id)
    (throw (ex-info "Season not found" {:id id}))))

