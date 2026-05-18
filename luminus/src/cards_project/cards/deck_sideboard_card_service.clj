(ns cards_project.cards.deck-sideboard-card-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.deck-sideboard-card-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-deck-sideboard-card
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- increment-behavior! [id amount]
  (throw (ex-info "increment not implemented" {:id id})))

(defn- decrement-behavior! [id amount]
  (throw (ex-info "decrement not implemented" {:id id})))

(defn increment!
  [id amount]
  (if (queries/get-deck-sideboard-card-by-id db-spec {:id id})
    (increment-behavior! id amount)
    (throw (ex-info "DeckSideboardCard not found" {:id id}))))

(defn decrement!
  [id amount]
  (if (queries/get-deck-sideboard-card-by-id db-spec {:id id})
    (decrement-behavior! id amount)
    (throw (ex-info "DeckSideboardCard not found" {:id id}))))

