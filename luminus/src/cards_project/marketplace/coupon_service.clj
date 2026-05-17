(ns cards_project.marketplace.coupon-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.coupon-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-coupon
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- is-valid-behavior! [id]
  (throw (ex-info "is_valid not implemented" {:id id})))

(defn- is-applicable-to-order-behavior! [id order-total]
  (throw (ex-info "is_applicable_to_order not implemented" {:id id})))

(defn- redeem-behavior! [id]
  (throw (ex-info "redeem not implemented" {:id id})))

(defn- deactivate-behavior! [id]
  (throw (ex-info "deactivate not implemented" {:id id})))

(defn redeem!
  [id]
  (if (queries/get-coupon-by-id db-spec {:id id})
    (redeem-behavior! id)
    (throw (ex-info "Coupon not found" {:id id}))))

(defn deactivate!
  [id]
  (if (queries/get-coupon-by-id db-spec {:id id})
    (deactivate-behavior! id)
    (throw (ex-info "Coupon not found" {:id id}))))

