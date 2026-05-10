(ns cards_project.players.achievement-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.achievement-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-achievement! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :description :icon_url :points :rarity :is_hidden}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO achievements ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-achievement! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :description :icon_url :points :rarity :is_hidden}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE achievements SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes achievements-routes

  (GET "/api/achievements" []
    (resp/response (queries/get-all-achievement db-spec)))

  (POST "/api/achievements" {params :body}
    (let [new-id (insert-achievement! params)
          record  (or (queries/get-achievement-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/achievements/:id" [id]
    (if-let [record (queries/get-achievement-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/achievements/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-achievement! int-id params)
      (if-let [record (queries/get-achievement-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/achievements/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-achievement! int-id params)
      (if-let [record (queries/get-achievement-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/achievements/:id" [id]
    (queries/delete-achievement! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
