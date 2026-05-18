(ns cards_project.marketplace.order-item-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.order-item-queries :as queries]
            [cards_project.marketplace.order-item-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- order-item-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-order-item-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :quantity)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Order item quantity must be greater than zero"))
    (when-not (let [v (get m :price_at_purchase)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Price at purchase must not be negative"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-order-item! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:quantity :price_at_purchase :foil :order_id :product_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO order_items ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-order-item! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:quantity :price_at_purchase :foil :order_id :product_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE order_items SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes order-items-routes

  (GET "/api/order_items" []
    (resp/response (queries/get-all-order-item db-spec)))

  (POST "/api/order_items" {params :body}
    (try
      (let [kw (order-item-kw-params params)]
        (validate-order-item-rules! kw)
        (let [new-id (insert-order-item! params)
              record  (or (queries/get-order-item-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/order_items/:id" [id]
    (if-let [record (queries/get-order-item-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/order_items/:id" [id :as {params :body}]
    (try
      (let [kw (order-item-kw-params params)]
        (validate-order-item-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-order-item! int-id params)
          (if-let [record (queries/get-order-item-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/order_items/:id" [id :as {params :body}]
    (try
      (let [kw (order-item-kw-params params)]
        (validate-order-item-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-order-item! int-id params)
          (if-let [record (queries/get-order-item-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/order_items/:id" [id]
    (queries/delete-order-item! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/order_items/:id/total" [id]
    (let [result (svc/line-total! (Integer/parseInt id))]
      (resp/response {:result result})))
)
