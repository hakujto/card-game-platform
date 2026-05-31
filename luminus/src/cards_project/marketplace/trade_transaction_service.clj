(ns cards_project.marketplace.trade-transaction-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.trade-transaction-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-trade-transaction
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- complete-behavior! [id]
  ; TODO: implement complete
  nil)

(defn- refund-behavior! [id]
  ; TODO: implement refund
  nil)

(defn- open-dispute-behavior! [id reason]
  ; TODO: implement open_dispute
  nil)

(defn- seller-net-behavior! [id]
  ; TODO: implement seller_net
  nil)

(defn complete!
  [id]
  (if-let [record (queries/get-trade-transaction-by-id db-spec {:id id})]
    (complete-behavior! id)
    (throw (ex-info "TradeTransaction not found" {:id id}))))

(defn refund!
  [id]
  (if-let [record (queries/get-trade-transaction-by-id db-spec {:id id})]
    (refund-behavior! id)
    (throw (ex-info "TradeTransaction not found" {:id id}))))

(defn open-dispute!
  [id reason]
  (if-let [record (queries/get-trade-transaction-by-id db-spec {:id id})]
    (open-dispute-behavior! id reason)
    (throw (ex-info "TradeTransaction not found" {:id id}))))

(defn seller-net!
  [id]
  (if-let [record (queries/get-trade-transaction-by-id db-spec {:id id})]
    (seller-net-behavior! id)
    (throw (ex-info "TradeTransaction not found" {:id id}))))

