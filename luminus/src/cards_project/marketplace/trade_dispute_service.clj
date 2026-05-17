(ns cards_project.marketplace.trade-dispute-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.trade-dispute-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-trade-dispute
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- escalate-behavior! [id]
  (throw (ex-info "escalate not implemented" {:id id})))

(defn- resolve-behavior! [id resolution-text]
  (throw (ex-info "resolve not implemented" {:id id})))

(defn- review-behavior! [id]
  (throw (ex-info "review not implemented" {:id id})))

(defn escalate!
  [id]
  (if (queries/get-trade-dispute-by-id db-spec {:id id})
    (escalate-behavior! id)
    (throw (ex-info "TradeDispute not found" {:id id}))))

(defn resolve!
  [id resolution-text]
  (if (queries/get-trade-dispute-by-id db-spec {:id id})
    (resolve-behavior! id resolution-text)
    (throw (ex-info "TradeDispute not found" {:id id}))))

(defn review!
  [id]
  (if (queries/get-trade-dispute-by-id db-spec {:id id})
    (review-behavior! id)
    (throw (ex-info "TradeDispute not found" {:id id}))))

