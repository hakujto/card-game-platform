(ns cards_project.marketplace.trade-listing-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.trade-listing-queries :as queries]
            [cards_project.marketplace.trade-listing-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- trade-listing-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-trade-listing-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :quantity)] (or (nil? v) (and (>= (->num v) 1) (<= (->num v) 9999))))
      (swap! errors conj "Listing quantity must be between 1 and 9999"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-trade-listing-implies! [m]
  (let [errors (atom [])]
    (when (and (= (get m :listing_type) "FixedPrice") (not (some? (get m :asking_price))))
      (swap! errors conj "Fixed price listing must have an asking price"))
    (when (and (= (get m :listing_type) "Auction") (not (and (some? (get m :auction_start_price)) (some? (get m :auction_end_time)))))
      (swap! errors conj "Auction listing must have a start price and end time"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-trade-listing! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :listing_type :asking_price :auction_start_price :auction_current_bid :auction_end_time :foil :condition :quantity :description :expires_at :seller_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO trade_listings ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-trade-listing! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :listing_type :asking_price :auction_start_price :auction_current_bid :auction_end_time :foil :condition :quantity :description :expires_at :seller_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE trade_listings SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defn- apply-projection-trade-listing [record]
  (when record
    (let [m (let [m (let [m record] (-> m (dissoc :created_at) (assoc :created_at (get m :created_at))))] (-> m (dissoc :expires_at) (assoc :expires_at (get m :expires_at))))] (-> m (dissoc :auction_end_time) (assoc :auction_end_time (get m :auction_end_time))))))

(defroutes trade-listings-routes

  (GET "/api/trade_listings" {params :query-params}
    (let [q (or (get params "q") "")]
      (resp/response (map apply-projection-trade-listing (filter #(or (empty? q) (or (clojure.string/includes? (str (get % :description "")) q))) (queries/get-all-trade-listing db-spec))))))

  (POST "/api/trade_listings" {params :body}
    (try
      (let [kw (trade-listing-kw-params params)]
        (validate-trade-listing-rules! kw)
        (validate-trade-listing-implies! kw)
        (let [new-id (insert-trade-listing! params)
              record  (or (queries/get-trade-listing-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response (apply-projection-trade-listing record)) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/trade_listings/:id" [id]
    (if-let [record (queries/get-trade-listing-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response (apply-projection-trade-listing record))
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PATCH "/api/trade_listings/:id" [id :as {params :body}]
    (try
      (let [kw (trade-listing-kw-params params)]
        (validate-trade-listing-rules! kw)
        (validate-trade-listing-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-trade-listing! int-id params)
          (if-let [record (queries/get-trade-listing-by-id db-spec {:id int-id})]
            (resp/response (apply-projection-trade-listing record))
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))


  (POST "/api/trade_listings/:id/close" [id]
    (svc/close! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (PATCH "/api/trade_listings/:id/extend" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        days (get params :days)]
      (svc/extend! int-id days)
      (-> (resp/response nil) (resp/status 204))))

  (DELETE "/api/trade_listings/:id/cancel" [id]
    (svc/cancel! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/trade_listings/:id/expired" [id]
    (let [result (svc/is-expired! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/trade_listings/:id/finalize" [id]
    (svc/finalize-auction! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (PATCH "/api/trade_listings/:id/transitions/pending-to-active" [id]
    (try
      (let [record (svc/transition-pending-to-active! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/trade_listings/:id/transitions/active-to-sold" [id]
    (try
      (let [record (svc/transition-active-to-sold! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/trade_listings/:id/transitions/active-to-expired" [id]
    (try
      (let [record (svc/transition-active-to-expired! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/trade_listings/:id/transitions/active-to-cancelled" [id]
    (try
      (let [record (svc/transition-active-to-cancelled! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/trade_listings/:id/transitions/sold-to-active" [id]
    (try
      (let [record (svc/transition-sold-to-active! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/trade_listings/:id/transitions/expired-to-active" [id]
    (try
      (let [record (svc/transition-expired-to-active! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))
)
