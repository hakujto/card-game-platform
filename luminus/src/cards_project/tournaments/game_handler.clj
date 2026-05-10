(ns cards_project.tournaments.game-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.game-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-game! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:game_number :winner_side :turns_played :duration_seconds :ended_by :replay_url :match_id :winner_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO games ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-game! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:game_number :winner_side :turns_played :duration_seconds :ended_by :replay_url :match_id :winner_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE games SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes games-routes

  (GET "/api/games" []
    (resp/response (queries/get-all-game db-spec)))

  (POST "/api/games" {params :body}
    (let [new-id (insert-game! params)
          record  (or (queries/get-game-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/games/:id" [id]
    (if-let [record (queries/get-game-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/games/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-game! int-id params)
      (if-let [record (queries/get-game-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/games/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-game! int-id params)
      (if-let [record (queries/get-game-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/games/:id" [id]
    (queries/delete-game! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
