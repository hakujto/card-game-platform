(ns cards_project.marketplace.order-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.order-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-order! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:status :total :discount_applied :currency :payment_method :payment_reference :shipping_address :tracking_number :paid_at :shipped_at :player_id :items_id :coupon_id}
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:status :total :discount_applied :currency :payment_method :payment_reference :shipping_address :tracking_number :paid_at :shipped_at :player_id :items_id :coupon_id}
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
    (let [new-id (insert-order! params)
          record  (or (queries/get-order-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/orders/:id" [id]
    (if-let [record (queries/get-order-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/orders/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-order! int-id params)
      (if-let [record (queries/get-order-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/orders/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-order! int-id params)
      (if-let [record (queries/get-order-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/orders/:id" [id]
    (queries/delete-order! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
