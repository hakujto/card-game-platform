(ns cards_project.marketplace.trade-transaction-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.trade-transaction-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-trade-transaction! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:final_price :platform_fee :status :completed_at :listing_id :buyer_id :seller_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE trade_transactions SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes trade-transactions-routes

  (GET "/api/trade_transactions" []
    (resp/response (queries/get-all-trade-transaction db-spec)))

  (POST "/api/trade_transactions" {params :body}
    (let [new-id (insert-trade-transaction! params)
          record  (or (queries/get-trade-transaction-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/trade_transactions/:id" [id]
    (if-let [record (queries/get-trade-transaction-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/trade_transactions/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-trade-transaction! int-id params)
      (if-let [record (queries/get-trade-transaction-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/trade_transactions/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-trade-transaction! int-id params)
      (if-let [record (queries/get-trade-transaction-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/trade_transactions/:id" [id]
    (queries/delete-trade-transaction! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
