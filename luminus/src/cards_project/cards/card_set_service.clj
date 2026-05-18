(ns cards_project.cards.card-set-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.card-set-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-card-set
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- is-legal-in-standard-behavior! [id]
  (throw (ex-info "is_legal_in_standard not implemented" {:id id})))

(defn- is-legal-in-format-behavior! [id format]
  (throw (ex-info "is_legal_in_format not implemented" {:id id})))

(defn- card-count-by-rarity-behavior! [id rarity]
  (throw (ex-info "card_count_by_rarity not implemented" {:id id})))

(defn- rotate-out-behavior! [id]
  (throw (ex-info "rotate_out not implemented" {:id id})))

(defn is-legal-in-standard!
  [id]
  (if (queries/get-card-set-by-id db-spec {:id id})
    (is-legal-in-standard-behavior! id)
    (throw (ex-info "CardSet not found" {:id id}))))

(defn is-legal-in-format!
  [id format]
  (if (queries/get-card-set-by-id db-spec {:id id})
    (is-legal-in-format-behavior! id format)
    (throw (ex-info "CardSet not found" {:id id}))))

(defn card-count-by-rarity!
  [id rarity]
  (if (queries/get-card-set-by-id db-spec {:id id})
    (card-count-by-rarity-behavior! id rarity)
    (throw (ex-info "CardSet not found" {:id id}))))

(defn rotate-out!
  [id]
  (if (queries/get-card-set-by-id db-spec {:id id})
    (rotate-out-behavior! id)
    (throw (ex-info "CardSet not found" {:id id}))))

