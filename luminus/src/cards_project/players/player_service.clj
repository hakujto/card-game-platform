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
  (throw (ex-info "promote not implemented" {:id id})))

(defn- demote-behavior! [id]
  (throw (ex-info "demote not implemented" {:id id})))

(defn- record-win-behavior! [id]
  (throw (ex-info "record_win not implemented" {:id id})))

(defn- record-loss-behavior! [id]
  (throw (ex-info "record_loss not implemented" {:id id})))

(defn- win-rate-behavior! [id]
  (throw (ex-info "win_rate not implemented" {:id id})))

(defn- verify-behavior! [id]
  (throw (ex-info "verify not implemented" {:id id})))

(defn- update-rating-behavior! [id delta]
  (throw (ex-info "update_rating not implemented" {:id id})))

(defn promote!
  [id]
  (if (queries/get-player-by-id db-spec {:id id})
    (promote-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn demote!
  [id]
  (if (queries/get-player-by-id db-spec {:id id})
    (demote-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn record-win!
  [id]
  (if (queries/get-player-by-id db-spec {:id id})
    (record-win-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn record-loss!
  [id]
  (if (queries/get-player-by-id db-spec {:id id})
    (record-loss-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn win-rate!
  [id]
  (if (queries/get-player-by-id db-spec {:id id})
    (win-rate-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn verify!
  [id]
  (if (queries/get-player-by-id db-spec {:id id})
    (verify-behavior! id)
    (throw (ex-info "Player not found" {:id id}))))

(defn update-rating!
  [id delta]
  (if (queries/get-player-by-id db-spec {:id id})
    (update-rating-behavior! id delta)
    (throw (ex-info "Player not found" {:id id}))))

