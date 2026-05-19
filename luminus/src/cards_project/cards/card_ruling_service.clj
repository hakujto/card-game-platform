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
  ; TODO: implement is_current
  nil)

(defn- supersedes-previous-behavior! [id]
  ; TODO: implement supersedes_previous
  nil)

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

