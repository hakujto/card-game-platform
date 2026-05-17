(ns cards_project.cards.deck-tag-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.deck-tag-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-deck-tag
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- rename-behavior! [id new-name]
  (throw (ex-info "rename not implemented" {:id id})))

(defn- merge-into-behavior! [id target-tag-id]
  (throw (ex-info "merge_into not implemented" {:id id})))

(defn merge-into!
  [id target-tag-id]
  (if (queries/get-deck-tag-by-id db-spec {:id id})
    (merge-into-behavior! id target-tag-id)
    (throw (ex-info "DeckTag not found" {:id id}))))

