(ns cards_project.marketplace.trade-bid-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.trade-bid-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-trade-bid
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- outbid-by-behavior! [id new-amount]
  (throw (ex-info "outbid_by not implemented" {:id id})))

(defn- retract-behavior! [id]
  (throw (ex-info "retract not implemented" {:id id})))

(defn outbid-by!
  [id new-amount]
  (if (queries/get-trade-bid-by-id db-spec {:id id})
    (outbid-by-behavior! id new-amount)
    (throw (ex-info "TradeBid not found" {:id id}))))

(defn retract!
  [id]
  (if (queries/get-trade-bid-by-id db-spec {:id id})
    (retract-behavior! id)
    (throw (ex-info "TradeBid not found" {:id id}))))

