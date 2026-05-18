(ns cards_project.marketplace.order-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.order-queries :as queries]
            [cards_project.marketplace.order-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- order-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-order-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :total)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Order total must not be negative"))
    (when-not (let [v (get m :discount_applied)] (or (nil? v) (<= (->num v) (->num (get m :total)))))
      (swap! errors conj "Discount applied cannot exceed order total"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-order-implies! [m]
  (let [errors (atom [])]
    (when (and (= (get m :status) "Paid") (not (some? (get m :paid_at))))
      (swap! errors conj "Paid order must have paid_at set"))
    (when (and (= (get m :status) "Shipped") (not (some? (get m :tracking_number))))
      (swap! errors conj "Shipped order must have a tracking number"))
    (when (and (some? (get m :shipped_at)) (not (= (get m :status) "Shipped")))
      (swap! errors conj "shipped_at_requires_shipped_status"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-order! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :total :discount_applied :currency :payment_method :payment_reference :shipping_address :tracking_number :paid_at :shipped_at :player_id :coupon_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO orders ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-order! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :total :discount_applied :currency :payment_method :payment_reference :shipping_address :tracking_number :paid_at :shipped_at :player_id :coupon_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE orders SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes orders-routes

  (GET "/api/orders" []
    (resp/response (queries/get-all-order db-spec)))

  (POST "/api/orders" {params :body}
    (try
      (let [kw (order-kw-params params)]
        (validate-order-rules! kw)
        (validate-order-implies! kw)
        (let [new-id (insert-order! params)
              record  (or (queries/get-order-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/orders/:id" [id]
    (if-let [record (queries/get-order-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/orders/:id" [id :as {params :body}]
    (try
      (let [kw (order-kw-params params)]
        (validate-order-rules! kw)
        (validate-order-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-order! int-id params)
          (if-let [record (queries/get-order-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/orders/:id" [id :as {params :body}]
    (try
      (let [kw (order-kw-params params)]
        (validate-order-rules! kw)
        (validate-order-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-order! int-id params)
          (if-let [record (queries/get-order-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/orders/:id" [id]
    (queries/delete-order! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (DELETE "/api/orders/:id/cancel" [id]
    (svc/cancel! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/orders/:id/pay" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        payment-ref (get params :payment-ref)
          result  (svc/pay! int-id payment-ref)]
      (resp/response {:result result})))

  (GET "/api/orders/:id/total" [id]
    (let [result (svc/calculate-total! (Integer/parseInt id))]
      (resp/response {:result result})))

  (PATCH "/api/orders/:id/discount" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        percent (get params :percent)
          result  (svc/apply-discount! int-id percent)]
      (resp/response {:result result})))

  (POST "/api/orders/:id/refund" [id]
    (svc/refund! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
