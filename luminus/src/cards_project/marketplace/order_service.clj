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
  ; TODO: implement cancel
  nil)

(defn- pay-behavior! [id payment-ref]
  ; TODO: implement pay
  nil)

(defn- process-payment-behavior! [id]
  ; TODO: implement process_payment
  nil)

(defn- calculate-total-behavior! [id]
  ; TODO: implement calculate_total
  nil)

(defn- apply-discount-behavior! [id percent]
  ; TODO: implement apply_discount
  nil)

(defn- refund-behavior! [id]
  ; TODO: implement refund
  nil)

(defn- notify-shipped-behavior! [id]
  ; TODO: implement notify_shipped
  nil)

; ── Lifecycle state machine ─────────────────────────────────────────
(def ^:private allowed-transitions
  {   "Pending" ["Paid", "Cancelled"]
   "Paid" ["Processing", "Cancelled"]
   "Processing" ["Shipped"]
   "Shipped" ["Completed"]
   "Completed" ["Refunded"]})

(defn- assert-transition! [current to]
  (let [allowed (get allowed-transitions current [])]
    (when-not (some #(= % to) allowed)
      (throw (ex-info (str "Transition " current " -> " to " not allowed")
                      {:status 409})))))

(defn transition-pending-to-paid!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Paid")
      (when (nil? (get record :payment_method))
        (throw (ex-info "payment_method is required for Pending -> Paid" {:status 422})))
      (jdbc/execute-one! db-spec
        ["UPDATE orders SET status = ? WHERE id = ?" "Paid" id])
      (process-payment-behavior! id) ; @after
      (queries/get-order-by-id db-spec {:id id}))
    (throw (ex-info "Order not found" {:id id :status 404}))))

(defn transition-paid-to-processing!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Processing")
      (jdbc/execute-one! db-spec
        ["UPDATE orders SET status = ? WHERE id = ?" "Processing" id])
      (queries/get-order-by-id db-spec {:id id}))
    (throw (ex-info "Order not found" {:id id :status 404}))))

(defn transition-processing-to-shipped!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Shipped")
      (when (nil? (get record :tracking_number))
        (throw (ex-info "tracking_number is required for Processing -> Shipped" {:status 422})))
      (jdbc/execute-one! db-spec
        ["UPDATE orders SET status = ? WHERE id = ?" "Shipped" id])
      (notify-shipped-behavior! id) ; @after
      (queries/get-order-by-id db-spec {:id id}))
    (throw (ex-info "Order not found" {:id id :status 404}))))

(defn transition-shipped-to-completed!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Completed")
      (jdbc/execute-one! db-spec
        ["UPDATE orders SET status = ? WHERE id = ?" "Completed" id])
      (queries/get-order-by-id db-spec {:id id}))
    (throw (ex-info "Order not found" {:id id :status 404}))))

(defn transition-pending-to-cancelled!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Cancelled")
      (jdbc/execute-one! db-spec
        ["UPDATE orders SET status = ? WHERE id = ?" "Cancelled" id])
      (cancel-behavior! id) ; @after
      (queries/get-order-by-id db-spec {:id id}))
    (throw (ex-info "Order not found" {:id id :status 404}))))

(defn transition-paid-to-cancelled!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Cancelled")
      (jdbc/execute-one! db-spec
        ["UPDATE orders SET status = ? WHERE id = ?" "Cancelled" id])
      (cancel-behavior! id) ; @after
      (queries/get-order-by-id db-spec {:id id}))
    (throw (ex-info "Order not found" {:id id :status 404}))))

(defn transition-completed-to-refunded!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Refunded")
      (jdbc/execute-one! db-spec
        ["UPDATE orders SET status = ? WHERE id = ?" "Refunded" id])
      (refund-behavior! id) ; @after
      (queries/get-order-by-id db-spec {:id id}))
    (throw (ex-info "Order not found" {:id id :status 404}))))

(defn transition-refunded-to-completed!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (throw (ex-info "Transition Refunded -> Completed is not allowed" {:status 409}))
    (throw (ex-info "Order not found" {:id id :status 404}))))

(defn transition-completed-to-cancelled!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (throw (ex-info "Transition Completed -> Cancelled is not allowed" {:status 409}))
    (throw (ex-info "Order not found" {:id id :status 404}))))

(defn cancel!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (cancel-behavior! id)
    (throw (ex-info "Order not found" {:id id}))))

(defn pay!
  [id payment-ref]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (pay-behavior! id payment-ref)
    (throw (ex-info "Order not found" {:id id}))))

(defn process-payment!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (process-payment-behavior! id)
    (throw (ex-info "Order not found" {:id id}))))

(defn calculate-total!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (calculate-total-behavior! id)
    (throw (ex-info "Order not found" {:id id}))))

(defn apply-discount!
  [id percent]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (apply-discount-behavior! id percent)
    (throw (ex-info "Order not found" {:id id}))))

(defn refund!
  [id]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (refund-behavior! id)
    (throw (ex-info "Order not found" {:id id}))))

; ── Lifecycle hooks ─────────────────────────────────────────────────
(defn- notify-status-change-hook! [record]
  ; TODO: implement notify_status_change
  record)

; triggered by @on(status = Shipped)
(defn set-status!
  [id value]
  (if-let [record (queries/get-order-by-id db-spec {:id id})]
    (do
      (jdbc/execute-one! db-spec
        ["UPDATE orders SET status = ? WHERE id = ?" value id])
      (when (= (str value) "Shipped")
        (notify-shipped-behavior! id)))
    (throw (ex-info "Order not found" {:id id}))))

