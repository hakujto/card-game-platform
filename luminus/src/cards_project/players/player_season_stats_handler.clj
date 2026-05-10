(ns cards_project.players.player-season-stats-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-season-stats-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-player-season-stats! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:wins :losses :draws :tournament_wins :highest_rank :season_points :player_id :season_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO player_season_statses ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-player-season-stats! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:wins :losses :draws :tournament_wins :highest_rank :season_points :player_id :season_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE player_season_statses SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes player-season-statses-routes

  (GET "/api/player_season_statses" []
    (resp/response (queries/get-all-player-season-stats db-spec)))

  (POST "/api/player_season_statses" {params :body}
    (let [new-id (insert-player-season-stats! params)
          record  (or (queries/get-player-season-stats-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/player_season_statses/:id" [id]
    (if-let [record (queries/get-player-season-stats-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/player_season_statses/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-player-season-stats! int-id params)
      (if-let [record (queries/get-player-season-stats-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/player_season_statses/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-player-season-stats! int-id params)
      (if-let [record (queries/get-player-season-stats-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/player_season_statses/:id" [id]
    (queries/delete-player-season-stats! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
