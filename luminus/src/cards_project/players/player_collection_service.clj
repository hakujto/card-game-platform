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
  ; TODO: implement add
  nil)

(defn- remove-behavior! [id quantity]
  ; TODO: implement remove
  nil)

(defn- estimated-value-behavior! [id]
  ; TODO: implement estimated_value
  nil)

(defn add!
  [id quantity]
  (if-let [record (queries/get-player-collection-by-id db-spec {:id id})]
    (add-behavior! id quantity)
    (throw (ex-info "PlayerCollection not found" {:id id}))))

(defn remove!
  [id quantity]
  (if-let [record (queries/get-player-collection-by-id db-spec {:id id})]
    (remove-behavior! id quantity)
    (throw (ex-info "PlayerCollection not found" {:id id}))))

(defn estimated-value!
  [id]
  (if-let [record (queries/get-player-collection-by-id db-spec {:id id})]
    (estimated-value-behavior! id)
    (throw (ex-info "PlayerCollection not found" {:id id}))))

