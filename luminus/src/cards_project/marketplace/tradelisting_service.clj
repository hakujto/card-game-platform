(ns cards_project.marketplace.tradelisting-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.tradelisting-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-tradelisting
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- close-behavior! [id]
  (throw (ex-info "close not implemented" {:id id})))

(defn- extend-behavior! [id days]
  (throw (ex-info "extend not implemented" {:id id})))

(defn- cancel-behavior! [id]
  (throw (ex-info "cancel not implemented" {:id id})))

(defn- is-expired-behavior! [id]
  (throw (ex-info "is_expired not implemented" {:id id})))

(defn- finalize-auction-behavior! [id]
  (throw (ex-info "finalize_auction not implemented" {:id id})))

(defn close!
  [id]
  (if (queries/get-tradelisting-by-id db-spec {:id id})
    (close-behavior! id)
    (throw (ex-info "Tradelisting not found" {:id id}))))

(defn extend!
  [id days]
  (if (queries/get-tradelisting-by-id db-spec {:id id})
    (extend-behavior! id days)
    (throw (ex-info "Tradelisting not found" {:id id}))))

(defn cancel!
  [id]
  (if (queries/get-tradelisting-by-id db-spec {:id id})
    (cancel-behavior! id)
    (throw (ex-info "Tradelisting not found" {:id id}))))

; triggered by @on(status = Sold)
(defn set-status!
  [id value]
  (if-let [record (queries/get-tradelisting-by-id db-spec {:id id})]
    (do
      (jdbc/execute-one! db-spec
        ["UPDATE tradelistings SET status = ? WHERE id = ?" value id])
      (when (= (clojure.string/upper-case (str value)) "SOLD")
        (finalize-auction-behavior! id)))
    (throw (ex-info "Tradelisting not found" {:id id}))))

