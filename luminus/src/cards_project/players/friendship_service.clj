(ns cards_project.players.friendship-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.friendship-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-friendship
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- accept-behavior! [id]
  (throw (ex-info "accept not implemented" {:id id})))

(defn- decline-behavior! [id]
  (throw (ex-info "decline not implemented" {:id id})))

(defn- block-behavior! [id]
  (throw (ex-info "block not implemented" {:id id})))

(defn accept!
  [id]
  (if (queries/get-friendship-by-id db-spec {:id id})
    (accept-behavior! id)
    (throw (ex-info "Friendship not found" {:id id}))))

(defn decline!
  [id]
  (if (queries/get-friendship-by-id db-spec {:id id})
    (decline-behavior! id)
    (throw (ex-info "Friendship not found" {:id id}))))

(defn block!
  [id]
  (if (queries/get-friendship-by-id db-spec {:id id})
    (block-behavior! id)
    (throw (ex-info "Friendship not found" {:id id}))))

