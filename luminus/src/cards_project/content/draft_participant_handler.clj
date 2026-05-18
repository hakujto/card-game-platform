(ns cards_project.content.draft-participant-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.draft-participant-queries :as queries]
            [cards_project.content.draft-participant-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- draft-participant-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-draft-participant-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :seat_number)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Seat number must be greater than zero"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-draft-participant! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:seat_number :joined_at :session_id :player_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO draft_participants ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-draft-participant! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:seat_number :joined_at :session_id :player_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE draft_participants SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes draft-participants-routes

  (GET "/api/draft_participants" []
    (resp/response (queries/get-all-draft-participant db-spec)))

  (POST "/api/draft_participants" {params :body}
    (try
      (let [kw (draft-participant-kw-params params)]
        (validate-draft-participant-rules! kw)
        (let [new-id (insert-draft-participant! params)
              record  (or (queries/get-draft-participant-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/draft_participants/:id" [id]
    (if-let [record (queries/get-draft-participant-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/draft_participants/:id" [id :as {params :body}]
    (try
      (let [kw (draft-participant-kw-params params)]
        (validate-draft-participant-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-draft-participant! int-id params)
          (if-let [record (queries/get-draft-participant-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/draft_participants/:id" [id :as {params :body}]
    (try
      (let [kw (draft-participant-kw-params params)]
        (validate-draft-participant-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-draft-participant! int-id params)
          (if-let [record (queries/get-draft-participant-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/draft_participants/:id" [id]
    (queries/delete-draft-participant! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/draft_participants/:id/pick" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        card-id (get params :card-id)
        pack-number (get params :pack-number)]
      (svc/pick-card! int-id card-id pack-number)
      (-> (resp/response nil) (resp/status 204))))

  (GET "/api/draft_participants/:id/card-count" [id]
    (let [result (svc/drafted-card-count! (Integer/parseInt id))]
      (resp/response {:result result})))
)
