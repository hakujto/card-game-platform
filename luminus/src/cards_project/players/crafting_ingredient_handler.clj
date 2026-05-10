(ns cards_project.players.crafting-ingredient-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.crafting-ingredient-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-crafting-ingredient! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:quantity :recipe_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO crafting_ingredients ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-crafting-ingredient! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:quantity :recipe_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE crafting_ingredients SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes crafting-ingredients-routes

  (GET "/api/crafting_ingredients" []
    (resp/response (queries/get-all-crafting-ingredient db-spec)))

  (POST "/api/crafting_ingredients" {params :body}
    (let [new-id (insert-crafting-ingredient! params)
          record  (or (queries/get-crafting-ingredient-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/crafting_ingredients/:id" [id]
    (if-let [record (queries/get-crafting-ingredient-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/crafting_ingredients/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-crafting-ingredient! int-id params)
      (if-let [record (queries/get-crafting-ingredient-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/crafting_ingredients/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-crafting-ingredient! int-id params)
      (if-let [record (queries/get-crafting-ingredient-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/crafting_ingredients/:id" [id]
    (queries/delete-crafting-ingredient! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
