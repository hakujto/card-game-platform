(ns cards_project.cards.card-ability-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.card-ability-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-card-ability
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- is-usable-at-behavior! [id timing]
  ; TODO: implement is_usable_at
  nil)

(defn- describe-behavior! [id]
  ; TODO: implement describe
  nil)

(defn is-usable-at!
  [id timing]
  (if (queries/get-card-ability-by-id db-spec {:id id})
    (is-usable-at-behavior! id timing)
    (throw (ex-info "CardAbility not found" {:id id}))))

(defn describe!
  [id]
  (if (queries/get-card-ability-by-id db-spec {:id id})
    (describe-behavior! id)
    (throw (ex-info "CardAbility not found" {:id id}))))

