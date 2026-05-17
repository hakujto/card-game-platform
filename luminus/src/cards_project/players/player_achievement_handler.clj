(ns cards_project.players.player-achievement-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-achievement-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- player-achievement-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-player-achievement-implies! [m]
  (let [errors (atom [])]
    (when (and (true? (get m :is_completed)) (not (let [v (get m :progress)] (or (nil? v) (> (->num v) 0)))))
      (swap! errors conj "Completed achievement must have progress greater than zero"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-player-achievement! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
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
    (try
      (let [kw (player-achievement-kw-params params)]
        (validate-player-achievement-implies! kw)
        (let [new-id (insert-player-achievement! params)
              record  (or (queries/get-player-achievement-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/player_achievements/:id" [id]
    (if-let [record (queries/get-player-achievement-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/player_achievements/:id" [id :as {params :body}]
    (try
      (let [kw (player-achievement-kw-params params)]
        (validate-player-achievement-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-player-achievement! int-id params)
          (if-let [record (queries/get-player-achievement-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/player_achievements/:id" [id :as {params :body}]
    (try
      (let [kw (player-achievement-kw-params params)]
        (validate-player-achievement-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-player-achievement! int-id params)
          (if-let [record (queries/get-player-achievement-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/player_achievements/:id" [id]
    (queries/delete-player-achievement! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))
)
