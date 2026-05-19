(ns cards_project.marketplace.trade-listing-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.trade-listing-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-trade-listing
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- close-behavior! [id]
  ; TODO: implement close
  nil)

(defn- extend-behavior! [id days]
  ; TODO: implement extend
  nil)

(defn- cancel-behavior! [id]
  ; TODO: implement cancel
  nil)

(defn- is-expired-behavior! [id]
  ; TODO: implement is_expired
  nil)

(defn- finalize-auction-behavior! [id]
  ; TODO: implement finalize_auction
  nil)

; ── Lifecycle state machine ─────────────────────────────────────────
(def ^:private allowed-transitions
  {   "Pending" ["Active"]
   "Active" ["Sold", "Expired", "Cancelled"]})

(defn- assert-transition! [current to]
  (let [allowed (get allowed-transitions current [])]
    (when-not (some #(= % to) allowed)
      (throw (ex-info (str "Transition " current " -> " to " not allowed")
                      {:status 409})))))

(defn transition-pending-to-active!
  [id]
  (if-let [record (queries/get-trade-listing-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Active")
      (when (nil? (get record :quantity))
        (throw (ex-info "quantity is required for Pending -> Active" {:status 422})))
      (jdbc/execute-one! db-spec
        ["UPDATE trade_listings SET status = ? WHERE id = ?" "Active" id])
      (queries/get-trade-listing-by-id db-spec {:id id}))
    (throw (ex-info "TradeListing not found" {:id id :status 404}))))

(defn transition-active-to-sold!
  [id]
  (if-let [record (queries/get-trade-listing-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Sold")
      (jdbc/execute-one! db-spec
        ["UPDATE trade_listings SET status = ? WHERE id = ?" "Sold" id])
      (finalize-auction-behavior! id) ; @after
      (queries/get-trade-listing-by-id db-spec {:id id}))
    (throw (ex-info "TradeListing not found" {:id id :status 404}))))

(defn transition-active-to-expired!
  [id]
  (if-let [record (queries/get-trade-listing-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Expired")
      (jdbc/execute-one! db-spec
        ["UPDATE trade_listings SET status = ? WHERE id = ?" "Expired" id])
      (close-behavior! id) ; @after
      (queries/get-trade-listing-by-id db-spec {:id id}))
    (throw (ex-info "TradeListing not found" {:id id :status 404}))))

(defn transition-active-to-cancelled!
  [id]
  (if-let [record (queries/get-trade-listing-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Cancelled")
      (jdbc/execute-one! db-spec
        ["UPDATE trade_listings SET status = ? WHERE id = ?" "Cancelled" id])
      (cancel-behavior! id) ; @after
      (queries/get-trade-listing-by-id db-spec {:id id}))
    (throw (ex-info "TradeListing not found" {:id id :status 404}))))

(defn transition-sold-to-active!
  [id]
  (if-let [record (queries/get-trade-listing-by-id db-spec {:id id})]
    (throw (ex-info "Transition Sold -> Active is not allowed" {:status 409}))
    (throw (ex-info "TradeListing not found" {:id id :status 404}))))

(defn transition-expired-to-active!
  [id]
  (if-let [record (queries/get-trade-listing-by-id db-spec {:id id})]
    (throw (ex-info "Transition Expired -> Active is not allowed" {:status 409}))
    (throw (ex-info "TradeListing not found" {:id id :status 404}))))

(defn close!
  [id]
  (if (queries/get-trade-listing-by-id db-spec {:id id})
    (close-behavior! id)
    (throw (ex-info "TradeListing not found" {:id id}))))

(defn extend!
  [id days]
  (if (queries/get-trade-listing-by-id db-spec {:id id})
    (extend-behavior! id days)
    (throw (ex-info "TradeListing not found" {:id id}))))

(defn cancel!
  [id]
  (if (queries/get-trade-listing-by-id db-spec {:id id})
    (cancel-behavior! id)
    (throw (ex-info "TradeListing not found" {:id id}))))

(defn is-expired!
  [id]
  (if (queries/get-trade-listing-by-id db-spec {:id id})
    (is-expired-behavior! id)
    (throw (ex-info "TradeListing not found" {:id id}))))

(defn finalize-auction!
  [id]
  (if (queries/get-trade-listing-by-id db-spec {:id id})
    (finalize-auction-behavior! id)
    (throw (ex-info "TradeListing not found" {:id id}))))

; triggered by @on(status = Sold)
(defn set-status!
  [id value]
  (if-let [record (queries/get-trade-listing-by-id db-spec {:id id})]
    (do
      (jdbc/execute-one! db-spec
        ["UPDATE trade_listings SET status = ? WHERE id = ?" value id])
      (when (= (clojure.string/upper-case (str value)) "SOLD")
        (finalize-auction-behavior! id)))
    (throw (ex-info "TradeListing not found" {:id id}))))

