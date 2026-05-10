(ns cards_project.cards.card-ability-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.card-ability-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-card-ability! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:ability_type :keyword :ability_text :timing :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO card_abilities ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-card-ability! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:ability_type :keyword :ability_text :timing :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE card_abilities SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes card-abilities-routes

  (GET "/api/card_abilities" []
    (resp/response (queries/get-all-card-ability db-spec)))

  (POST "/api/card_abilities" {params :body}
    (let [new-id (insert-card-ability! params)
          record  (or (queries/get-card-ability-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/card_abilities/:id" [id]
    (if-let [record (queries/get-card-ability-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/card_abilities/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-card-ability! int-id params)
      (if-let [record (queries/get-card-ability-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/card_abilities/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-card-ability! int-id params)
      (if-let [record (queries/get-card-ability-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/card_abilities/:id" [id]
    (queries/delete-card-ability! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
