(ns cards_project.players.player-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-player! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:display_name :rank :rating :peak_rating :bio :country_code :avatar_url :preferred_format :is_verified :last_active_at :user_id :season_stats_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO players ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-player! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:display_name :rank :rating :peak_rating :bio :country_code :avatar_url :preferred_format :is_verified :last_active_at :user_id :season_stats_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE players SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes players-routes

  (GET "/api/players" []
    (resp/response (queries/get-all-player db-spec)))

  (POST "/api/players" {params :body}
    (let [new-id (insert-player! params)
          record  (or (queries/get-player-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/players/:id" [id]
    (if-let [record (queries/get-player-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/players/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-player! int-id params)
      (if-let [record (queries/get-player-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/players/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-player! int-id params)
      (if-let [record (queries/get-player-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/players/:id" [id]
    (queries/delete-player! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
