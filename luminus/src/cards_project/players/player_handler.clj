(ns cards_project.players.player-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-queries :as queries]
            [cards_project.players.player-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- player-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-player-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :rating)] (or (nil? v) (and (>= (->num v) 0) (<= (->num v) 9999))))
      (swap! errors conj "Rating must be between 0 and 9999"))
    (when-not (let [v (get m :peak_rating)] (or (nil? v) (>= (->num v) (->num (get m :rating)))))
      (swap! errors conj "Peak rating must be greater than or equal to current rating"))
    (when-not (some? (get m :display_name))
      (swap! errors conj "Display name must not be empty"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-player! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:display_name :rank :rating :peak_rating :bio :country_code :avatar_url :preferred_format :is_verified :last_active_at :user_id}
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:display_name :rank :rating :peak_rating :bio :country_code :avatar_url :preferred_format :is_verified :last_active_at :user_id}
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
    (try
      (let [kw (player-kw-params params)]
        (validate-player-rules! kw)
        (let [new-id (insert-player! params)
              record  (or (queries/get-player-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/players/:id" [id]
    (if-let [record (queries/get-player-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/players/:id" [id :as {params :body}]
    (try
      (let [kw (player-kw-params params)]
        (validate-player-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-player! int-id params)
          (if-let [record (queries/get-player-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/players/:id" [id :as {params :body}]
    (try
      (let [kw (player-kw-params params)]
        (validate-player-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-player! int-id params)
          (if-let [record (queries/get-player-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/players/:id" [id]
    (queries/delete-player! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/players/:id/promote" [id]
    (let [result (svc/promote! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/players/:id/demote" [id]
    (let [result (svc/demote! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/players/:id/win" [id]
    (svc/record-win! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/players/:id/loss" [id]
    (svc/record-loss! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/players/:id/win-rate" [id]
    (let [result (svc/win-rate! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/players/:id/verify" [id]
    (svc/verify! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (PATCH "/api/players/:id/rating" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        delta (get params :delta)]
      (svc/update-rating! int-id delta)
      (-> (resp/response nil) (resp/status 204))))
)
