(ns cards_project.tournaments.game-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.game-queries :as queries]
            [cards_project.tournaments.game-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- game-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-game-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :game_number)] (or (nil? v) (and (>= (->num v) 1) (<= (->num v) 3))))
      (swap! errors conj "Game number must be between 1 and 3 (best-of-3)"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-game-implies! [m]
  (let [errors (atom [])]
    (when (and (some? (get m :turns_played)) (not (let [v (get m :turns_played)] (or (nil? v) (> (->num v) 0)))))
      (swap! errors conj "Turns played must be greater than zero"))
    (when (and (some? (get m :duration_seconds)) (not (let [v (get m :duration_seconds)] (or (nil? v) (> (->num v) 0)))))
      (swap! errors conj "Game duration must be greater than zero"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-game! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
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
    (try
      (let [kw (game-kw-params params)]
        (validate-game-rules! kw)
        (validate-game-implies! kw)
        (let [new-id (insert-game! params)
              record  (or (queries/get-game-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/games/:id" [id]
    (if-let [record (queries/get-game-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/games/:id" [id :as {params :body}]
    (try
      (let [kw (game-kw-params params)]
        (validate-game-rules! kw)
        (validate-game-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-game! int-id params)
          (if-let [record (queries/get-game-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/games/:id" [id :as {params :body}]
    (try
      (let [kw (game-kw-params params)]
        (validate-game-rules! kw)
        (validate-game-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-game! int-id params)
          (if-let [record (queries/get-game-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/games/:id" [id]
    (queries/delete-game! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/games/:id/winner" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        winner-side (get params :winner-side)]
      (svc/record-winner! int-id winner-side)
      (-> (resp/response nil) (resp/status 204))))
)
