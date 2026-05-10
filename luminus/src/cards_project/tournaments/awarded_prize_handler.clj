(ns cards_project.tournaments.awarded-prize-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.awarded-prize-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-awarded-prize! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:final_placement :awarded_at :claimed :claimed_at :prize_id :player_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO awarded_prizes ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-awarded-prize! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:final_placement :awarded_at :claimed :claimed_at :prize_id :player_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE awarded_prizes SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes awarded-prizes-routes

  (GET "/api/awarded_prizes" []
    (resp/response (queries/get-all-awarded-prize db-spec)))

  (POST "/api/awarded_prizes" {params :body}
    (let [new-id (insert-awarded-prize! params)
          record  (or (queries/get-awarded-prize-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/awarded_prizes/:id" [id]
    (if-let [record (queries/get-awarded-prize-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/awarded_prizes/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-awarded-prize! int-id params)
      (if-let [record (queries/get-awarded-prize-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/awarded_prizes/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-awarded-prize! int-id params)
      (if-let [record (queries/get-awarded-prize-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/awarded_prizes/:id" [id]
    (queries/delete-awarded-prize! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
