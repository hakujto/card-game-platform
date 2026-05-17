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
  (throw (ex-info "complete not implemented" {:id id})))

(defn- refund-behavior! [id]
  (throw (ex-info "refund not implemented" {:id id})))

(defn- open-dispute-behavior! [id reason]
  (throw (ex-info "open_dispute not implemented" {:id id})))

(defn- seller-net-behavior! [id]
  (throw (ex-info "seller_net not implemented" {:id id})))

(defn complete!
  [id]
  (if (queries/get-trade-transaction-by-id db-spec {:id id})
    (complete-behavior! id)
    (throw (ex-info "TradeTransaction not found" {:id id}))))

(defn refund!
  [id]
  (if (queries/get-trade-transaction-by-id db-spec {:id id})
    (refund-behavior! id)
    (throw (ex-info "TradeTransaction not found" {:id id}))))

(defn open-dispute!
  [id reason]
  (if (queries/get-trade-transaction-by-id db-spec {:id id})
    (open-dispute-behavior! id reason)
    (throw (ex-info "TradeTransaction not found" {:id id}))))

