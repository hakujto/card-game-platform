(ns cards_project.marketplace.tradelisting-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.tradelisting-queries :as queries]
            [cards_project.marketplace.tradelisting-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- tradelisting-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-tradelisting-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :quantity)] (or (nil? v) (and (>= (->num v) 1) (<= (->num v) 9999))))
      (swap! errors conj "Listing quantity must be between 1 and 9999"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-tradelisting-implies! [m]
  (let [errors (atom [])]
    (when (and (= (get m :listing_type) "FixedPrice") (not (some? (get m :asking_price))))
      (swap! errors conj "Fixed price listing must have an asking price"))
    (when (and (= (get m :listing_type) "Auction") (not (and (some? (get m :auction_start_price)) (some? (get m :auction_end_time)))))
      (swap! errors conj "Auction listing must have a start price and end time"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-tradelisting! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:listing_type :asking_price :auction_start_price :auction_current_bid :auction_end_time :foil :condition :quantity :status :description :expires_at :seller_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO tradelistings ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-tradelisting! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:listing_type :asking_price :auction_start_price :auction_current_bid :auction_end_time :foil :condition :quantity :status :description :expires_at :seller_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE tradelistings SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes tradelistings-routes

  (GET "/api/tradelistings" []
    (resp/response (queries/get-all-tradelisting db-spec)))

  (POST "/api/tradelistings" {params :body}
    (try
      (let [kw (tradelisting-kw-params params)]
        (validate-tradelisting-rules! kw)
        (validate-tradelisting-implies! kw)
        (let [new-id (insert-tradelisting! params)
              record  (or (queries/get-tradelisting-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/tradelistings/:id" [id]
    (if-let [record (queries/get-tradelisting-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/tradelistings/:id" [id :as {params :body}]
    (try
      (let [kw (tradelisting-kw-params params)]
        (validate-tradelisting-rules! kw)
        (validate-tradelisting-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-tradelisting! int-id params)
          (if-let [record (queries/get-tradelisting-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/tradelistings/:id" [id :as {params :body}]
    (try
      (let [kw (tradelisting-kw-params params)]
        (validate-tradelisting-rules! kw)
        (validate-tradelisting-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-tradelisting! int-id params)
          (if-let [record (queries/get-tradelisting-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/tradelistings/:id" [id]
    (queries/delete-tradelisting! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tradelistings/:id/close" [id]
    (svc/close! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (PATCH "/api/tradelistings/:id/extend" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        days (get params :days)]
      (svc/extend! int-id days)
      (-> (resp/response nil) (resp/status 204))))

  (DELETE "/api/tradelistings/:id/cancel" [id]
    (svc/cancel! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
