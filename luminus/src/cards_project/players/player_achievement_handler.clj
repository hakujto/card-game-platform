(ns cards_project.players.player-achievement-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-achievement-queries :as queries]
            [cards_project.players.player-achievement-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- player-achievement-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-player-achievement-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :progress)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Achievement progress must not be negative"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

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

(defn- apply-projection-player-achievement [record]
  (when record
    (let [m record] (-> m (dissoc :earned_at) (assoc :earned_at (get m :earned_at))))))

(defroutes player-achievements-routes

  (GET "/api/player_achievements" []
    (resp/response (map apply-projection-player-achievement (queries/get-all-player-achievement db-spec))))

  (GET "/api/player_achievements/:id" [id]
    (if-let [record (queries/get-player-achievement-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response (apply-projection-player-achievement record))
      (-> (resp/response {:error "Not found"}) (resp/status 404))))


  (PATCH "/api/player_achievements/:id/progress" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        amount (get params :amount)]
      (svc/increment-progress! int-id amount)
      (-> (resp/response nil) (resp/status 204))))

  (POST "/api/player_achievements/:id/complete" [id]
    (svc/complete! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
