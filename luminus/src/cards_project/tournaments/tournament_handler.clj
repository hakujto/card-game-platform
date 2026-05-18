(ns cards_project.tournaments.tournament-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-queries :as queries]
            [cards_project.tournaments.tournament-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- tournament-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-tournament-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :max_players)] (or (nil? v) (and (>= (->num v) 2) (<= (->num v) 512))))
      (swap! errors conj "Tournament must allow between 2 and 512 players"))
    (when-not (let [v (get m :entry_fee)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Entry fee must not be negative"))
    (when-not (let [v (get m :prize_pool)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Prize pool must not be negative"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-tournament-implies! [m]
  (let [errors (atom [])]
    (when (and (some? (get m :end_time)) (not (let [lhs (get m :end_time) rhs (get m :start_time)] (or (nil? lhs) (nil? rhs) (pos? (compare lhs rhs))))))
      (swap! errors conj "End time must be after start time"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-tournament! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :description :format :tournament_type :status :max_players :entry_fee :prize_pool :start_time :end_time :is_online :location :rules_text :season_id :organizer_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO tournaments ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-tournament! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :description :format :tournament_type :status :max_players :entry_fee :prize_pool :start_time :end_time :is_online :location :rules_text :season_id :organizer_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE tournaments SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes tournaments-routes

  (GET "/api/tournaments" []
    (resp/response (queries/get-all-tournament db-spec)))

  (POST "/api/tournaments" {params :body}
    (try
      (let [kw (tournament-kw-params params)]
        (validate-tournament-rules! kw)
        (validate-tournament-implies! kw)
        (let [new-id (insert-tournament! params)
              record  (or (queries/get-tournament-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/tournaments/:id" [id]
    (if-let [record (queries/get-tournament-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/tournaments/:id" [id :as {params :body}]
    (try
      (let [kw (tournament-kw-params params)]
        (validate-tournament-rules! kw)
        (validate-tournament-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-tournament! int-id params)
          (if-let [record (queries/get-tournament-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/tournaments/:id" [id :as {params :body}]
    (try
      (let [kw (tournament-kw-params params)]
        (validate-tournament-rules! kw)
        (validate-tournament-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-tournament! int-id params)
          (if-let [record (queries/get-tournament-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/tournaments/:id" [id]
    (queries/delete-tournament! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tournaments/:id/start" [id]
    (svc/start! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tournaments/:id/cancel" [id]
    (svc/cancel! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tournaments/:id/complete" [id]
    (svc/complete! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tournaments/:id/rounds" [id]
    (svc/generate-round! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/tournaments/:id/prizes" [id]
    (let [result (svc/calculate-prize-distribution! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/tournaments/:id/register" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        player-id (get params :player-id)
        deck-id (get params :deck-id)]
      (svc/register-player! int-id player-id deck-id)
      (-> (resp/response nil) (resp/status 204))))

  (GET "/api/tournaments/:id/full" [id]
    (let [result (svc/is-full! (Integer/parseInt id))]
      (resp/response {:result result})))
)
