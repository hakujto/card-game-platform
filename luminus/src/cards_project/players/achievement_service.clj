(ns cards_project.players.achievement-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.achievement-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-achievement
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- point-value-behavior! [id multiplier]
  (throw (ex-info "point_value not implemented" {:id id})))

(defn- reveal-behavior! [id]
  (throw (ex-info "reveal not implemented" {:id id})))

(defn point-value!
  [id multiplier]
  (if (queries/get-achievement-by-id db-spec {:id id})
    (point-value-behavior! id multiplier)
    (throw (ex-info "Achievement not found" {:id id}))))

(defn reveal!
  [id]
  (if (queries/get-achievement-by-id db-spec {:id id})
    (reveal-behavior! id)
    (throw (ex-info "Achievement not found" {:id id}))))

