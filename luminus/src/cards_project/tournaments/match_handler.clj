(ns cards_project.tournaments.match-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.match-queries :as queries]
            [cards_project.tournaments.match-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- match-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-match-rules! [m]
  (let [errors (atom [])]
    (when-not (and (let [v (get m :player1_wins)] (or (nil? v) (>= (->num v) 0))) (let [v (get m :player2_wins)] (or (nil? v) (>= (->num v) 0))))
      (swap! errors conj "Win counts must not be negative"))
    (when-not (and (let [v (get m :player1_wins)] (or (nil? v) (and (>= (->num v) 0) (<= (->num v) 2)))) (let [v (get m :player2_wins)] (or (nil? v) (and (>= (->num v) 0) (<= (->num v) 2)))))
      (swap! errors conj "Win counts cannot exceed 2 in a best-of-3 match"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-match-implies! [m]
  (let [errors (atom [])]
    (when (and (= (get m :status) "BYE") (not (nil? (get m :player2))))
      (swap! errors conj "BYE match must not have a second player"))
    (when (and (some? (get m :ended_at)) (not (let [lhs (get m :ended_at) rhs (get m :started_at)] (or (nil? lhs) (nil? rhs) (pos? (compare lhs rhs))))))
      (swap! errors conj "Match end time must be after start time"))
    (when (and (= (get m :status) "Completed") (not (some? (get m :started_at))))
      (swap! errors conj "Completed match must have a start time"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-match! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:table_number :status :player1_wins :player2_wins :started_at :ended_at :result_notes :round_id :player1_id :player2_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO matches ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-match! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:table_number :status :player1_wins :player2_wins :started_at :ended_at :result_notes :round_id :player1_id :player2_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE matches SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes matches-routes

  (GET "/api/matches" []
    (resp/response (queries/get-all-match db-spec)))

  (POST "/api/matches" {params :body}
    (try
      (let [kw (match-kw-params params)]
        (validate-match-rules! kw)
        (validate-match-implies! kw)
        (let [new-id (insert-match! params)
              record  (or (queries/get-match-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/matches/:id" [id]
    (if-let [record (queries/get-match-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/matches/:id" [id :as {params :body}]
    (try
      (let [kw (match-kw-params params)]
        (validate-match-rules! kw)
        (validate-match-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-match! int-id params)
          (if-let [record (queries/get-match-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/matches/:id" [id :as {params :body}]
    (try
      (let [kw (match-kw-params params)]
        (validate-match-rules! kw)
        (validate-match-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-match! int-id params)
          (if-let [record (queries/get-match-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/matches/:id" [id]
    (queries/delete-match! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/matches/:id/record" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        p1-wins (get params :p1-wins)
        p2-wins (get params :p2-wins)]
      (svc/record-result! int-id p1-wins p2-wins)
      (-> (resp/response nil) (resp/status 204))))

  (GET "/api/matches/:id/winner" [id]
    (let [result (svc/determine-winner! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/matches/:id/concede" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        player-id (get params :player-id)]
      (svc/concede! int-id player-id)
      (-> (resp/response nil) (resp/status 204))))

  (POST "/api/matches/:id/draw" [id]
    (svc/draw! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
