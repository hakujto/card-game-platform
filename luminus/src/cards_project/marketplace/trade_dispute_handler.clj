(ns cards_project.marketplace.trade-dispute-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.trade-dispute-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-trade-dispute! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:reason :description :status :resolution :opened_at :resolved_at :transaction_id :opened_by_id :resolved_by_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO trade_disputes ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-trade-dispute! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:reason :description :status :resolution :opened_at :resolved_at :transaction_id :opened_by_id :resolved_by_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE trade_disputes SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes trade-disputes-routes

  (GET "/api/trade_disputes" []
    (resp/response (queries/get-all-trade-dispute db-spec)))

  (POST "/api/trade_disputes" {params :body}
    (let [new-id (insert-trade-dispute! params)
          record  (or (queries/get-trade-dispute-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/trade_disputes/:id" [id]
    (if-let [record (queries/get-trade-dispute-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/trade_disputes/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-trade-dispute! int-id params)
      (if-let [record (queries/get-trade-dispute-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/trade_disputes/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-trade-dispute! int-id params)
      (if-let [record (queries/get-trade-dispute-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/trade_disputes/:id" [id]
    (queries/delete-trade-dispute! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
