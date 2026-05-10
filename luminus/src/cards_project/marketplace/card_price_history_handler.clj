(ns cards_project.marketplace.card-price-history-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.card-price-history-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-card-price-history! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:price_date :avg_price :min_price :max_price :volume :foil :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO card_price_histories ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-card-price-history! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:price_date :avg_price :min_price :max_price :volume :foil :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE card_price_histories SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes card-price-histories-routes

  (GET "/api/card_price_histories" []
    (resp/response (queries/get-all-card-price-history db-spec)))

  (POST "/api/card_price_histories" {params :body}
    (let [new-id (insert-card-price-history! params)
          record  (or (queries/get-card-price-history-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/card_price_histories/:id" [id]
    (if-let [record (queries/get-card-price-history-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/card_price_histories/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-card-price-history! int-id params)
      (if-let [record (queries/get-card-price-history-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/card_price_histories/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-card-price-history! int-id params)
      (if-let [record (queries/get-card-price-history-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/card_price_histories/:id" [id]
    (queries/delete-card-price-history! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
