(ns cards_project.content.draft-session-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.draft-session-queries :as queries]
            [cards_project.content.draft-session-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- draft-session-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-draft-session-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :seats)] (or (nil? v) (and (>= (->num v) 2) (<= (->num v) 16))))
      (swap! errors conj "Draft session must have between 2 and 16 seats"))
    (when-not (let [v (get m :time_per_pick_seconds)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Time per pick must be greater than zero"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-draft-session-implies! [m]
  (let [errors (atom [])]
    (when (and (some? (get m :completed_at)) (not (= (get m :status) "Completed")))
      (swap! errors conj "completed_at can only be set when draft status is Completed"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-draft-session! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :draft_type :pack_contents :seats :time_per_pick_seconds :completed_at :card_set_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO draft_sessions ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-draft-session! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :draft_type :pack_contents :seats :time_per_pick_seconds :completed_at :card_set_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE draft_sessions SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defn- apply-projection-draft-session [record]
  (when record
    (let [m (let [m record] (-> m (dissoc :created_at) (assoc :created_at (get m :created_at))))] (-> m (dissoc :completed_at) (assoc :completed_at (get m :completed_at))))))

(defroutes draft-sessions-routes

  (GET "/api/draft_sessions" []
    (resp/response (map apply-projection-draft-session (queries/get-all-draft-session db-spec))))

  (POST "/api/draft_sessions" {params :body}
    (try
      (let [kw (draft-session-kw-params params)]
        (validate-draft-session-rules! kw)
        (validate-draft-session-implies! kw)
        (let [new-id (insert-draft-session! params)
              record  (or (queries/get-draft-session-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response (apply-projection-draft-session record)) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/draft_sessions/:id" [id]
    (if-let [record (queries/get-draft-session-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response (apply-projection-draft-session record))
      (-> (resp/response {:error "Not found"}) (resp/status 404))))


  (POST "/api/draft_sessions/:id/start" [id]
    (svc/start! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/draft_sessions/:id/abandon" [id]
    (svc/abandon! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/draft_sessions/:id/complete" [id]
    (svc/complete! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/draft_sessions/:id/full" [id]
    (let [result (svc/is-full! (Integer/parseInt id))]
      (resp/response {:result result})))

  (PATCH "/api/draft_sessions/:id/transitions/waitingforplayers-to-drafting" [id]
    (try
      (let [record (svc/transition-waiting-for-players-to-drafting! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/draft_sessions/:id/transitions/drafting-to-completed" [id]
    (try
      (let [record (svc/transition-drafting-to-completed! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/draft_sessions/:id/transitions/drafting-to-abandoned" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Admin" "Organizer"} user-role))
        (-> (resp/response {:error "Insufficient role for transition Drafting -> Abandoned"}) (resp/status 403))
        (try
          (let [record (svc/transition-drafting-to-abandoned! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/draft_sessions/:id/transitions/waitingforplayers-to-abandoned" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Admin" "Organizer"} user-role))
        (-> (resp/response {:error "Insufficient role for transition WaitingForPlayers -> Abandoned"}) (resp/status 403))
        (try
          (let [record (svc/transition-waiting-for-players-to-abandoned! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/draft_sessions/:id/transitions/completed-to-drafting" [id]
    (try
      (let [record (svc/transition-completed-to-drafting! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/draft_sessions/:id/transitions/abandoned-to-drafting" [id]
    (try
      (let [record (svc/transition-abandoned-to-drafting! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))
)
