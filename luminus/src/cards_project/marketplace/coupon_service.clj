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
  ; TODO: implement is_valid
  nil)

(defn- is-applicable-to-order-behavior! [id order-total]
  ; TODO: implement is_applicable_to_order
  nil)

(defn- redeem-behavior! [id]
  ; TODO: implement redeem
  nil)

(defn- deactivate-behavior! [id]
  ; TODO: implement deactivate
  nil)

(defn is-valid!
  [id]
  (if-let [record (queries/get-coupon-by-id db-spec {:id id})]
    (is-valid-behavior! id)
    (throw (ex-info "Coupon not found" {:id id}))))

(defn is-applicable-to-order!
  [id order-total]
  (if-let [record (queries/get-coupon-by-id db-spec {:id id})]
    (is-applicable-to-order-behavior! id order-total)
    (throw (ex-info "Coupon not found" {:id id}))))

(defn redeem!
  [id]
  (if-let [record (queries/get-coupon-by-id db-spec {:id id})]
    (if (not (= (get record :is_active) true))
      (throw (ex-info "Guard condition not met for redeem" {:status 422}))
      (redeem-behavior! id))
    (throw (ex-info "Coupon not found" {:id id}))))

(defn deactivate!
  [id]
  (if-let [record (queries/get-coupon-by-id db-spec {:id id})]
    (deactivate-behavior! id)
    (throw (ex-info "Coupon not found" {:id id}))))

