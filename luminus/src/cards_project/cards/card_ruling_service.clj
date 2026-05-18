(ns cards_project.cards.card-ruling-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.card-ruling-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-card-ruling
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- is-current-behavior! [id]
  (throw (ex-info "is_current not implemented" {:id id})))

(defn- supersedes-previous-behavior! [id]
  (throw (ex-info "supersedes_previous not implemented" {:id id})))

(defn is-current!
  [id]
  (if (queries/get-card-ruling-by-id db-spec {:id id})
    (is-current-behavior! id)
    (throw (ex-info "CardRuling not found" {:id id}))))

(defn supersedes-previous!
  [id]
  (if (queries/get-card-ruling-by-id db-spec {:id id})
    (supersedes-previous-behavior! id)
    (throw (ex-info "CardRuling not found" {:id id}))))

