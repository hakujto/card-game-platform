(ns cards_project.players.player-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-player
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- promote-behavior! [id]
  ; TODO: implement promote
  nil)

(defn- demote-behavior! [id]
  ; TODO: implement demote
  nil)

(defn- record-win-behavior! [id]
  ; TODO: implement record_win
  nil)

(defn- record-loss-behavior! [id]
  ; TODO: implement record_loss
  nil)

(defn- win-rate-behavior! [id]
  ; TODO: implement win_rate
  nil)

(defn- verify-behavior! [id]
  ; TODO: implement verify
  nil)

(defn- update-rating-behavior! [id delta]
  ; TODO: implement update_rating
  nil)

(defn promote!
  [id]
  (if-let [record (queries/get-player-by-id db-spec {:id id})]
    (promote-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn demote!
  [id]
  (if-let [record (queries/get-player-by-id db-spec {:id id})]
    (demote-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn record-win!
  [id]
  (if-let [record (queries/get-player-by-id db-spec {:id id})]
    (record-win-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn record-loss!
  [id]
  (if-let [record (queries/get-player-by-id db-spec {:id id})]
    (record-loss-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn win-rate!
  [id]
  (if-let [record (queries/get-player-by-id db-spec {:id id})]
    (win-rate-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn verify!
  ; @allow ["admin"] — check (get-in request [:identity :role]) in route middleware
  [id]
  (if-let [record (queries/get-player-by-id db-spec {:id id})]
    (verify-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn update-rating!
  [id delta]
  (if-let [record (queries/get-player-by-id db-spec {:id id})]
    (update-rating-behavior! id delta)
    (throw (ex-info "Player not found" {:id id}))))

; ── Lifecycle hooks ─────────────────────────────────────────────────
(defn- initialize-collection-hook! [record]
  ; TODO: implement initialize_collection
  record)

(defn- update-rank-hook! [record]
  ; TODO: implement update_rank
  record)

