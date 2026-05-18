(ns cards_project.marketplace.trade-bid-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.trade-bid-queries :as queries]
            [cards_project.marketplace.trade-bid-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- trade-bid-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-trade-bid-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :amount)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Bid amount must be greater than zero"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-trade-bid! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:amount :placed_at :is_winning :listing_id :bidder_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO trade_bids ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-trade-bid! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:amount :placed_at :is_winning :listing_id :bidder_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE trade_bids SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes trade-bids-routes

  (GET "/api/trade_bids" []
    (resp/response (queries/get-all-trade-bid db-spec)))

  (POST "/api/trade_bids" {params :body}
    (try
      (let [kw (trade-bid-kw-params params)]
        (validate-trade-bid-rules! kw)
        (let [new-id (insert-trade-bid! params)
              record  (or (queries/get-trade-bid-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/trade_bids/:id" [id]
    (if-let [record (queries/get-trade-bid-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/trade_bids/:id" [id :as {params :body}]
    (try
      (let [kw (trade-bid-kw-params params)]
        (validate-trade-bid-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-trade-bid! int-id params)
          (if-let [record (queries/get-trade-bid-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/trade_bids/:id" [id :as {params :body}]
    (try
      (let [kw (trade-bid-kw-params params)]
        (validate-trade-bid-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-trade-bid! int-id params)
          (if-let [record (queries/get-trade-bid-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/trade_bids/:id" [id]
    (queries/delete-trade-bid! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/trade_bids/:id/outbid" [id]
    (let [result (svc/outbid-by! (Integer/parseInt id))]
      (resp/response {:result result})))

  (DELETE "/api/trade_bids/:id" [id]
    (svc/retract! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
