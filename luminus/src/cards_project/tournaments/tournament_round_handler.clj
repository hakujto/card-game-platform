(ns cards_project.tournaments.tournament-round-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-round-queries :as queries]
            [cards_project.tournaments.tournament-round-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- tournament-round-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-tournament-round-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :round_number)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Round number must be greater than zero"))
    (when-not (let [v (get m :time_limit_minutes)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Round time limit must be greater than zero"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-tournament-round-implies! [m]
  (let [errors (atom [])]
    (when (and (some? (get m :ended_at)) (not (let [lhs (get m :ended_at) rhs (get m :started_at)] (or (nil? lhs) (nil? rhs) (pos? (compare lhs rhs))))))
      (swap! errors conj "Round end time must be after start time"))
    (when (and (= (get m :status) "Completed") (not (some? (get m :started_at))))
      (swap! errors conj "Completed round must have a start time"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-tournament-round! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:round_number :status :started_at :ended_at :time_limit_minutes :tournament_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO tournament_rounds ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-tournament-round! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:round_number :status :started_at :ended_at :time_limit_minutes :tournament_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE tournament_rounds SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes tournament-rounds-routes

  (GET "/api/tournament_rounds" []
    (resp/response (queries/get-all-tournament-round db-spec)))

  (POST "/api/tournament_rounds" {params :body}
    (try
      (let [kw (tournament-round-kw-params params)]
        (validate-tournament-round-rules! kw)
        (validate-tournament-round-implies! kw)
        (let [new-id (insert-tournament-round! params)
              record  (or (queries/get-tournament-round-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/tournament_rounds/:id" [id]
    (if-let [record (queries/get-tournament-round-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/tournament_rounds/:id" [id :as {params :body}]
    (try
      (let [kw (tournament-round-kw-params params)]
        (validate-tournament-round-rules! kw)
        (validate-tournament-round-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-tournament-round! int-id params)
          (if-let [record (queries/get-tournament-round-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/tournament_rounds/:id" [id :as {params :body}]
    (try
      (let [kw (tournament-round-kw-params params)]
        (validate-tournament-round-rules! kw)
        (validate-tournament-round-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-tournament-round! int-id params)
          (if-let [record (queries/get-tournament-round-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/tournament_rounds/:id" [id]
    (queries/delete-tournament-round! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tournament_rounds/:id/start" [id]
    (svc/start! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tournament_rounds/:id/complete" [id]
    (svc/complete! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tournament_rounds/:id/pairings" [id]
    (svc/generate-pairings! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/tournament_rounds/:id/time-expired" [id]
    (let [result (svc/is-time-expired! (Integer/parseInt id))]
      (resp/response {:result result})))
)
