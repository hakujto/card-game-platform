(ns cards_project.marketplace.order-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.order-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-order
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- cancel-behavior! [id]
  (throw (ex-info "cancel not implemented" {:id id})))

(defn- pay-behavior! [id payment-ref]
  (throw (ex-info "pay not implemented" {:id id})))

(defn- calculate-total-behavior! [id]
  (throw (ex-info "calculate_total not implemented" {:id id})))

(defn- apply-discount-behavior! [id percent]
  (throw (ex-info "apply_discount not implemented" {:id id})))

(defn- refund-behavior! [id]
  (throw (ex-info "refund not implemented" {:id id})))

(defn- notify-shipped-behavior! [id]
  (throw (ex-info "notify_shipped not implemented" {:id id})))

(defn cancel!
  [id]
  (if (queries/get-order-by-id db-spec {:id id})
    (cancel-behavior! id)
    (throw (ex-info "Order not found" {:id id}))))

(defn pay!
  [id payment-ref]
  (if (queries/get-order-by-id db-spec {:id id})
    (pay-behavior! id payment-ref)
    (throw (ex-info "Order not found" {:id id}))))

(defn calculate-total!
  [id]
  (if (queries/get-order-by-id db-spec {:id id})
    (calculate-total-behavior! id)
    (throw (ex-info "Order not found" {:id id}))))

(defn apply-discount!
  [id percent]
  (if (queries/get-order-by-id db-spec {:id id})
    (apply-discount-behavior! id percent)
    (throw (ex-info "Order not found" {:id id}))))

(defn refund!
  [id]
  (if (queries/get-order-by-id db-spec {:id id})
    (refund-behavior! id)
    (throw (ex-info "Order not found" {:id id}))))

; triggered by @on(status = Shipped)
(defn set-status!
  [id value]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (do
      (jdbc/execute-one! db-spec
        ["UPDATE orders SET status = ? WHERE id = ?" value id])
      (when (= (clojure.string/upper-case (str value)) "SHIPPED")
        (notify-shipped-behavior! id)))
    (throw (ex-info "Order not found" {:id id}))))

