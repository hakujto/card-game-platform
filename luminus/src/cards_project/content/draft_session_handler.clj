(ns cards_project.content.draft-session-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.draft-session-queries :as queries]
            [cards_project.content.draft-session-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- insert-draft-session! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :draft_type :seats :completed_at :card_set_id}
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
        allowed  #{:status :draft_type :seats :completed_at :card_set_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE draft_sessions SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes draft-sessions-routes

  (GET "/api/draft_sessions" []
    (resp/response (queries/get-all-draft-session db-spec)))

  (POST "/api/draft_sessions" {params :body}
    (try
      (let [new-id (insert-draft-session! params)
            record  (or (queries/get-draft-session-by-id db-spec {:id new-id}) {:id new-id})]
        (-> (resp/response record) (resp/status 201)))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/draft_sessions/:id" [id]
    (if-let [record (queries/get-draft-session-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/draft_sessions/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-draft-session! int-id params)
        (if-let [record (queries/get-draft-session-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/draft_sessions/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-draft-session! int-id params)
        (if-let [record (queries/get-draft-session-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/draft_sessions/:id" [id]
    (queries/delete-draft-session! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/draft_sessions/:id/start" [id]
    (svc/start! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/draft_sessions/:id/abandon" [id]
    (svc/abandon! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/draft_sessions/:id/complete" [id]
    (svc/complete! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
