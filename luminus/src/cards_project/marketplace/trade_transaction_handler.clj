(ns cards_project.marketplace.trade-transaction-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.trade-transaction-queries :as queries]
            [cards_project.marketplace.trade-transaction-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- trade-transaction-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-trade-transaction-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :platform_fee)] (or (nil? v) (<= (->num v) (->num (get m :final_price)))))
      (swap! errors conj "Platform fee cannot exceed the final price"))
    (when-not (let [v (get m :platform_fee)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Platform fee must not be negative"))
    (when-not (let [v (get m :final_price)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Transaction final price must be greater than zero"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-trade-transaction-implies! [m]
  (let [errors (atom [])]
    (when (and (= (get m :status) "Completed") (not (some? (get m :completed_at))))
      (swap! errors conj "Completed transaction must have a completed_at timestamp"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-trade-transaction! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:final_price :platform_fee :status :completed_at :listing_id :buyer_id :seller_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO trade_transactions ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-trade-transaction! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:final_price :platform_fee :status :completed_at :listing_id :buyer_id :seller_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE trade_transactions SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defn- apply-projection-trade-transaction [record]
  (when record
    (let [m record] (-> m (dissoc :completed_at) (assoc :completed_at (get m :completed_at))))))

(defroutes trade-transactions-routes

  (GET "/api/trade_transactions" []
    (resp/response (map apply-projection-trade-transaction (queries/get-all-trade-transaction db-spec))))

  (GET "/api/trade_transactions/:id" [id]
    (if-let [record (queries/get-trade-transaction-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response (apply-projection-trade-transaction record))
      (-> (resp/response {:error "Not found"}) (resp/status 404))))


  (POST "/api/trade_transactions/:id/complete" [id]
    (svc/complete! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/trade_transactions/:id/refund" [id]
    (svc/refund! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/trade_transactions/:id/dispute" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        reason (get params :reason)]
      (svc/open-dispute! int-id reason)
      (-> (resp/response nil) (resp/status 204))))

  (GET "/api/trade_transactions/:id/seller-net" [id]
    (let [result (svc/seller-net! (Integer/parseInt id))]
      (resp/response {:result result})))
)
