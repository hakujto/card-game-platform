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
  ; TODO: implement validate_size
  nil)

(defn- add-card-behavior! [id card-id quantity]
  ; TODO: implement add_card
  nil)

(defn- remove-card-behavior! [id card-id]
  ; TODO: implement remove_card
  nil)

(defn- win-rate-behavior! [id]
  ; TODO: implement win_rate
  nil)

(defn- clone-behavior! [id]
  ; TODO: implement clone
  nil)

(defn- publish-behavior! [id]
  ; TODO: implement publish
  nil)

(defn- unpublish-behavior! [id]
  ; TODO: implement unpublish
  nil)

(defn- certify-tournament-legal-behavior! [id]
  ; TODO: implement certify_tournament_legal
  nil)

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

