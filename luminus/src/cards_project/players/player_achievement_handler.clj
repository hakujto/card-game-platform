(ns cards_project.players.player-achievement-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-achievement-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-player-achievement! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:earned_at :progress :is_completed :player_id :achievement_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO player_achievements ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-player-achievement! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:earned_at :progress :is_completed :player_id :achievement_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE player_achievements SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes player-achievements-routes

  (GET "/api/player_achievements" []
    (resp/response (queries/get-all-player-achievement db-spec)))

  (POST "/api/player_achievements" {params :body}
    (let [new-id (insert-player-achievement! params)
          record  (or (queries/get-player-achievement-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/player_achievements/:id" [id]
    (if-let [record (queries/get-player-achievement-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/player_achievements/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-player-achievement! int-id params)
      (if-let [record (queries/get-player-achievement-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/player_achievements/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-player-achievement! int-id params)
      (if-let [record (queries/get-player-achievement-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/player_achievements/:id" [id]
    (queries/delete-player-achievement! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
