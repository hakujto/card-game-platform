(ns cards_project.cards.card-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.card-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-card
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- ban-behavior! [id]
  ; TODO: implement ban
  nil)

(defn- unban-behavior! [id]
  ; TODO: implement unban
  nil)

(defn- restrict-behavior! [id]
  ; TODO: implement restrict
  nil)

(defn- unrestrict-behavior! [id]
  ; TODO: implement unrestrict
  nil)

(defn- replace-behavior! [id data]
  ; TODO: implement replace
  nil)

(defn- calculate-value-behavior! [id]
  ; TODO: implement calculate_value
  nil)

(defn- apply-rarity-bonus-behavior! [id multiplier]
  ; TODO: implement apply_rarity_bonus
  nil)

(defn- is-legal-in-format-behavior! [id format]
  ; TODO: implement is_legal_in_format
  nil)

(defn ban!
  ; @allow ["admin" "moderator"] — check (get-in request [:identity :role]) in route middleware
  [id]
  (if-let [record (queries/get-card-by-id db-spec {:id id})]
    (ban-behavior! id)
    (throw (ex-info "Card not found" {:id id}))))

(defn unban!
  ; @allow ["admin" "moderator"] — check (get-in request [:identity :role]) in route middleware
  [id]
  (if-let [record (queries/get-card-by-id db-spec {:id id})]
    (unban-behavior! id)
    (throw (ex-info "Card not found" {:id id}))))

(defn restrict!
  ; @allow ["admin" "moderator"] — check (get-in request [:identity :role]) in route middleware
  [id]
  (if-let [record (queries/get-card-by-id db-spec {:id id})]
    (restrict-behavior! id)
    (throw (ex-info "Card not found" {:id id}))))

(defn unrestrict!
  ; @allow ["admin" "moderator"] — check (get-in request [:identity :role]) in route middleware
  [id]
  (if-let [record (queries/get-card-by-id db-spec {:id id})]
    (unrestrict-behavior! id)
    (throw (ex-info "Card not found" {:id id}))))

(defn replace!
  ; @allow ["admin"] — check (get-in request [:identity :role]) in route middleware
  [id data]
  (if-let [record (queries/get-card-by-id db-spec {:id id})]
    (replace-behavior! id data)
    (throw (ex-info "Card not found" {:id id}))))

(defn calculate-value!
  [id]
  (if-let [record (queries/get-card-by-id db-spec {:id id})]
    (calculate-value-behavior! id)
    (throw (ex-info "Card not found" {:id id}))))

(defn apply-rarity-bonus!
  [id multiplier]
  (if-let [record (queries/get-card-by-id db-spec {:id id})]
    (apply-rarity-bonus-behavior! id multiplier)
    (throw (ex-info "Card not found" {:id id}))))

(defn is-legal-in-format!
  [id format]
  (if-let [record (queries/get-card-by-id db-spec {:id id})]
    (is-legal-in-format-behavior! id format)
    (throw (ex-info "Card not found" {:id id}))))

; ── Lifecycle hooks ─────────────────────────────────────────────────
(defn- validate-legality-hook! [record]
  ; TODO: implement validate_legality
  record)

(defn- validate-not-in-use-hook! [record]
  ; TODO: implement validate_not_in_use
  record)

