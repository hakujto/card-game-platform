(ns cards_project.marketplace.order-item-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.order-item-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-order-item
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- line-total-behavior! [id]
  (throw (ex-info "line_total not implemented" {:id id})))

(defn line-total!
  [id]
  (if (queries/get-order-item-by-id db-spec {:id id})
    (line-total-behavior! id)
    (throw (ex-info "OrderItem not found" {:id id}))))

