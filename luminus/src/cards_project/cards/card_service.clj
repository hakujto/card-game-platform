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
  (throw (ex-info "ban not implemented" {:id id})))

(defn- unban-behavior! [id]
  (throw (ex-info "unban not implemented" {:id id})))

(defn- restrict-behavior! [id]
  (throw (ex-info "restrict not implemented" {:id id})))

(defn- unrestrict-behavior! [id]
  (throw (ex-info "unrestrict not implemented" {:id id})))

(defn- calculate-value-behavior! [id]
  (throw (ex-info "calculate_value not implemented" {:id id})))

(defn ban!
  [id]
  (if (queries/get-card-by-id db-spec {:id id})
    (ban-behavior! id)
    (throw (ex-info "Card not found" {:id id}))))

(defn unban!
  [id]
  (if (queries/get-card-by-id db-spec {:id id})
    (unban-behavior! id)
    (throw (ex-info "Card not found" {:id id}))))

(defn restrict!
  [id]
  (if (queries/get-card-by-id db-spec {:id id})
    (restrict-behavior! id)
    (throw (ex-info "Card not found" {:id id}))))

(defn unrestrict!
  [id]
  (if (queries/get-card-by-id db-spec {:id id})
    (unrestrict-behavior! id)
    (throw (ex-info "Card not found" {:id id}))))

(defn calculate-value!
  [id]
  (if (queries/get-card-by-id db-spec {:id id})
    (calculate-value-behavior! id)
    (throw (ex-info "Card not found" {:id id}))))

