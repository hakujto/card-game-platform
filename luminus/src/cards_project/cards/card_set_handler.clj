(ns cards_project.cards.card-set-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.card-set-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-card-set! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :code :release_date :set_type :total_cards :description :logo_url}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO card_sets ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-card-set! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :code :release_date :set_type :total_cards :description :logo_url}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE card_sets SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes card-sets-routes

  (GET "/api/card_sets" []
    (resp/response (queries/get-all-card-set db-spec)))

  (POST "/api/card_sets" {params :body}
    (let [new-id (insert-card-set! params)
          record  (or (queries/get-card-set-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/card_sets/:id" [id]
    (if-let [record (queries/get-card-set-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/card_sets/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-card-set! int-id params)
      (if-let [record (queries/get-card-set-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/card_sets/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-card-set! int-id params)
      (if-let [record (queries/get-card-set-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/card_sets/:id" [id]
    (queries/delete-card-set! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
