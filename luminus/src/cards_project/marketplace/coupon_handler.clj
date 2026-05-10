(ns cards_project.marketplace.coupon-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.coupon-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-coupon! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:code :discount_type :discount_value :min_order_value :max_uses :uses_count :valid_from :valid_until :is_active}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO coupons ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-coupon! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:code :discount_type :discount_value :min_order_value :max_uses :uses_count :valid_from :valid_until :is_active}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE coupons SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes coupons-routes

  (GET "/api/coupons" []
    (resp/response (queries/get-all-coupon db-spec)))

  (POST "/api/coupons" {params :body}
    (let [new-id (insert-coupon! params)
          record  (or (queries/get-coupon-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/coupons/:id" [id]
    (if-let [record (queries/get-coupon-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/coupons/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-coupon! int-id params)
      (if-let [record (queries/get-coupon-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/coupons/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-coupon! int-id params)
      (if-let [record (queries/get-coupon-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/coupons/:id" [id]
    (queries/delete-coupon! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
