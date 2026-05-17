(ns cards_project.players.player-collection-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-collection-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-player-collection
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- add-behavior! [id quantity]
  (throw (ex-info "add not implemented" {:id id})))

(defn- remove-behavior! [id quantity]
  (throw (ex-info "remove not implemented" {:id id})))

(defn- estimated-value-behavior! [id]
  (throw (ex-info "estimated_value not implemented" {:id id})))

(defn estimated-value!
  [id]
  (if (queries/get-player-collection-by-id db-spec {:id id})
    (estimated-value-behavior! id)
    (throw (ex-info "PlayerCollection not found" {:id id}))))

