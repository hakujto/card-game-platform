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
  ; TODO: implement escalate
  nil)

(defn- resolve-behavior! [id resolution-text]
  ; TODO: implement resolve
  nil)

(defn- close-resolved-behavior! [id]
  ; TODO: implement close_resolved
  nil)

(defn- review-behavior! [id]
  ; TODO: implement review
  nil)

; ── Lifecycle state machine ─────────────────────────────────────────
(def ^:private allowed-transitions
  {   "Open" ["UnderReview"]
   "UnderReview" ["Resolved", "Escalated"]
   "Escalated" ["Resolved"]})

(defn- assert-transition! [current to]
  (let [allowed (get allowed-transitions current [])]
    (when-not (some #(= % to) allowed)
      (throw (ex-info (str "Transition " current " -> " to " not allowed")
                      {:status 409})))))

(defn transition-open-to-under-review!
  [id]
  (if-let [record (queries/get-trade-dispute-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "UnderReview")
      (jdbc/execute-one! db-spec
        ["UPDATE trade_disputes SET status = ? WHERE id = ?" "UnderReview" id])
      (review-behavior! id) ; @after
      (queries/get-trade-dispute-by-id db-spec {:id id}))
    (throw (ex-info "TradeDispute not found" {:id id :status 404}))))

(defn transition-under-review-to-resolved!
  [id]
  (if-let [record (queries/get-trade-dispute-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Resolved")
      (when (nil? (get record :resolution))
        (throw (ex-info "resolution is required for UnderReview -> Resolved" {:status 422})))
      (jdbc/execute-one! db-spec
        ["UPDATE trade_disputes SET status = ? WHERE id = ?" "Resolved" id])
      (close-resolved-behavior! id) ; @after
      (queries/get-trade-dispute-by-id db-spec {:id id}))
    (throw (ex-info "TradeDispute not found" {:id id :status 404}))))

(defn transition-under-review-to-escalated!
  [id]
  (if-let [record (queries/get-trade-dispute-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Escalated")
      (jdbc/execute-one! db-spec
        ["UPDATE trade_disputes SET status = ? WHERE id = ?" "Escalated" id])
      (escalate-behavior! id) ; @after
      (queries/get-trade-dispute-by-id db-spec {:id id}))
    (throw (ex-info "TradeDispute not found" {:id id :status 404}))))

(defn transition-escalated-to-resolved!
  [id]
  (if-let [record (queries/get-trade-dispute-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Resolved")
      (when (nil? (get record :resolution))
        (throw (ex-info "resolution is required for Escalated -> Resolved" {:status 422})))
      (jdbc/execute-one! db-spec
        ["UPDATE trade_disputes SET status = ? WHERE id = ?" "Resolved" id])
      (close-resolved-behavior! id) ; @after
      (queries/get-trade-dispute-by-id db-spec {:id id}))
    (throw (ex-info "TradeDispute not found" {:id id :status 404}))))

(defn transition-resolved-to-open!
  [id]
  (if-let [record (queries/get-trade-dispute-by-id db-spec {:id id})]
    (throw (ex-info "Transition Resolved -> Open is not allowed" {:status 409}))
    (throw (ex-info "TradeDispute not found" {:id id :status 404}))))

(defn escalate!
  [id]
  (if-let [record (queries/get-trade-dispute-by-id db-spec {:id id})]
    (escalate-behavior! id)
    (throw (ex-info "TradeDispute not found" {:id id}))))

(defn resolve!
  [id resolution-text]
  (if-let [record (queries/get-trade-dispute-by-id db-spec {:id id})]
    (resolve-behavior! id resolution-text)
    (throw (ex-info "TradeDispute not found" {:id id}))))

(defn close-resolved!
  [id]
  (if-let [record (queries/get-trade-dispute-by-id db-spec {:id id})]
    (close-resolved-behavior! id)
    (throw (ex-info "TradeDispute not found" {:id id}))))

(defn review!
  [id]
  (if-let [record (queries/get-trade-dispute-by-id db-spec {:id id})]
    (review-behavior! id)
    (throw (ex-info "TradeDispute not found" {:id id}))))

