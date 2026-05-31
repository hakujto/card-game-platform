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
  ; TODO: implement activate
  nil)

(defn- deactivate-behavior! [id]
  ; TODO: implement deactivate
  nil)

(defn- finalize-rewards-behavior! [id]
  ; TODO: implement finalize_rewards
  nil)

(defn- is-ongoing-behavior! [id]
  ; TODO: implement is_ongoing
  nil)

(defn activate!
  [id]
  (if-let [record (queries/get-season-by-id db-spec {:id id})]
    (activate-behavior! id)
    (throw (ex-info "Season not found" {:id id}))))

(defn deactivate!
  [id]
  (if-let [record (queries/get-season-by-id db-spec {:id id})]
    (deactivate-behavior! id)
    (throw (ex-info "Season not found" {:id id}))))

(defn finalize-rewards!
  [id]
  (if-let [record (queries/get-season-by-id db-spec {:id id})]
    (finalize-rewards-behavior! id)
    (throw (ex-info "Season not found" {:id id}))))

(defn is-ongoing!
  [id]
  (if-let [record (queries/get-season-by-id db-spec {:id id})]
    (is-ongoing-behavior! id)
    (throw (ex-info "Season not found" {:id id}))))

