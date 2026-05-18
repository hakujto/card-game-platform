(ns cards_project.marketplace.product-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.product-queries :as queries]
            [cards_project.marketplace.product-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- product-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-product-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :price)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Product price must be greater than zero"))
    (when-not (let [v (get m :stock)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Product stock must not be negative"))
    (when-not (let [v (get m :discount_percent)] (or (nil? v) (and (>= (->num v) 0) (<= (->num v) 100))))
      (swap! errors conj "Product discount percent must be between 0 and 100"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-product! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :product_type :price :stock :active :discount_percent :description :image_url :featured :card_id :card_set_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO products ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-product! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :product_type :price :stock :active :discount_percent :description :image_url :featured :card_id :card_set_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE products SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes products-routes

  (GET "/api/products" []
    (resp/response (queries/get-all-product db-spec)))

  (POST "/api/products" {params :body}
    (try
      (let [kw (product-kw-params params)]
        (validate-product-rules! kw)
        (let [new-id (insert-product! params)
              record  (or (queries/get-product-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/products/:id" [id]
    (if-let [record (queries/get-product-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/products/:id" [id :as {params :body}]
    (try
      (let [kw (product-kw-params params)]
        (validate-product-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-product! int-id params)
          (if-let [record (queries/get-product-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/products/:id" [id :as {params :body}]
    (try
      (let [kw (product-kw-params params)]
        (validate-product-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-product! int-id params)
          (if-let [record (queries/get-product-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/products/:id" [id]
    (queries/delete-product! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/products/:id/activate" [id]
    (svc/activate! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/products/:id/deactivate" [id]
    (svc/deactivate! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (PATCH "/api/products/:id/discount" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        percent (get params :percent)
          result  (svc/apply-discount! int-id percent)]
      (resp/response {:result result})))

  (POST "/api/products/:id/restock" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        quantity (get params :quantity)]
      (svc/restock! int-id quantity)
      (-> (resp/response nil) (resp/status 204))))

  (GET "/api/products/:id/effective-price" [id]
    (let [result (svc/effective-price! (Integer/parseInt id))]
      (resp/response {:result result})))

  (GET "/api/products/:id/in-stock" [id]
    (let [result (svc/is-in-stock! (Integer/parseInt id))]
      (resp/response {:result result})))
)
