(ns cards_project.cards.deck-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.deck-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-deck
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- validate-size-behavior! [id]
  (throw (ex-info "validate_size not implemented" {:id id})))

(defn- add-card-behavior! [id card-id quantity]
  (throw (ex-info "add_card not implemented" {:id id})))

(defn- remove-card-behavior! [id card-id]
  (throw (ex-info "remove_card not implemented" {:id id})))

(defn- win-rate-behavior! [id]
  (throw (ex-info "win_rate not implemented" {:id id})))

(defn- clone-behavior! [id]
  (throw (ex-info "clone not implemented" {:id id})))

(defn- publish-behavior! [id]
  (throw (ex-info "publish not implemented" {:id id})))

(defn- unpublish-behavior! [id]
  (throw (ex-info "unpublish not implemented" {:id id})))

(defn- certify-tournament-legal-behavior! [id]
  (throw (ex-info "certify_tournament_legal not implemented" {:id id})))

(defn validate-size!
  [id]
  (if (queries/get-deck-by-id db-spec {:id id})
    (validate-size-behavior! id)
    (throw (ex-info "Deck not found" {:id id}))))

(defn add-card!
  [id card-id quantity]
  (if (queries/get-deck-by-id db-spec {:id id})
    (add-card-behavior! id card-id quantity)
    (throw (ex-info "Deck not found" {:id id}))))

(defn remove-card!
  [id card-id]
  (if (queries/get-deck-by-id db-spec {:id id})
    (remove-card-behavior! id card-id)
    (throw (ex-info "Deck not found" {:id id}))))

(defn win-rate!
  [id]
  (if (queries/get-deck-by-id db-spec {:id id})
    (win-rate-behavior! id)
    (throw (ex-info "Deck not found" {:id id}))))

(defn clone!
  [id]
  (if (queries/get-deck-by-id db-spec {:id id})
    (clone-behavior! id)
    (throw (ex-info "Deck not found" {:id id}))))

(defn publish!
  [id]
  (if (queries/get-deck-by-id db-spec {:id id})
    (publish-behavior! id)
    (throw (ex-info "Deck not found" {:id id}))))

(defn unpublish!
  [id]
  (if (queries/get-deck-by-id db-spec {:id id})
    (unpublish-behavior! id)
    (throw (ex-info "Deck not found" {:id id}))))

(defn certify-tournament-legal!
  [id]
  (if (queries/get-deck-by-id db-spec {:id id})
    (certify-tournament-legal-behavior! id)
    (throw (ex-info "Deck not found" {:id id}))))

