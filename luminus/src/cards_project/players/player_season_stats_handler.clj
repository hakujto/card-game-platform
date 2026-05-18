(ns cards_project.players.player-season-stats-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-season-stats-queries :as queries]
            [cards_project.players.player-season-stats-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- player-season-stats-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-player-season-stats-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :wins)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Season wins must not be negative"))
    (when-not (let [v (get m :losses)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Season losses must not be negative"))
    (when-not (let [v (get m :tournament_wins)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Season tournament wins must not be negative"))
    (when-not (let [v (get m :season_points)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Season points must not be negative"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-player-season-stats! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
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
    (try
      (let [kw (player-season-stats-kw-params params)]
        (validate-player-season-stats-rules! kw)
        (let [new-id (insert-player-season-stats! params)
              record  (or (queries/get-player-season-stats-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/player_season_statses/:id" [id]
    (if-let [record (queries/get-player-season-stats-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/player_season_statses/:id" [id :as {params :body}]
    (try
      (let [kw (player-season-stats-kw-params params)]
        (validate-player-season-stats-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-player-season-stats! int-id params)
          (if-let [record (queries/get-player-season-stats-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/player_season_statses/:id" [id :as {params :body}]
    (try
      (let [kw (player-season-stats-kw-params params)]
        (validate-player-season-stats-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-player-season-stats! int-id params)
          (if-let [record (queries/get-player-season-stats-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/player_season_statses/:id" [id]
    (queries/delete-player-season-stats! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/player_season_statses/:id/win-rate" [id]
    (let [result (svc/win-rate! (Integer/parseInt id))]
      (resp/response {:result result})))

  (PATCH "/api/player_season_statses/:id/points" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        points (get params :points)]
      (svc/add-points! int-id points)
      (-> (resp/response nil) (resp/status 204))))

  (POST "/api/player_season_statses/:id/tournament-win" [id]
    (svc/record-tournament-win! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
