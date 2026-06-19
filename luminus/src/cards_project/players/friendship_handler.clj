(ns cards_project.players.friendship-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.friendship-queries :as queries]
            [cards_project.players.friendship-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- insert-friendship! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :requester_id :receiver_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO friendships ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-friendship! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :requester_id :receiver_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE friendships SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defn- apply-projection-friendship [record]
  (when record
    (let [m record] (-> m (dissoc :created_at) (assoc :created_at (get m :created_at))))))

(defroutes friendships-routes

  (GET "/api/friendships" []
    (resp/response (map apply-projection-friendship (queries/get-all-friendship db-spec))))

  (POST "/api/friendships" {params :body}
    (try
      (let [new-id (insert-friendship! params)
            record  (or (queries/get-friendship-by-id db-spec {:id new-id}) {:id new-id})]
        (-> (resp/response (apply-projection-friendship record)) (resp/status 201)))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/friendships/:id" [id :as req]
    (if-let [record (queries/get-friendship-by-id db-spec {:id (Integer/parseInt id)})]
      (let [uid (get-in req [:headers "x-user-id"])]
        (if (= (str (:requester_id record)) uid)
          (resp/response (apply-projection-friendship record))
          (-> (resp/response {:error "You do not own this resource."}) (resp/status 403))))
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (DELETE "/api/friendships/:id" [id :as req]
    (if-let [record (queries/get-friendship-by-id db-spec {:id (Integer/parseInt id)})]
      (let [uid (get-in req [:headers "x-user-id"])]
        (if (= (str (:requester_id record)) uid)
          (do (queries/delete-friendship! db-spec {:id (Integer/parseInt id)})
              (-> (resp/response nil) (resp/status 204)))
          (-> (resp/response {:error "You do not own this resource."}) (resp/status 403))))
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (POST "/api/friendships/:id/accept" [id]
    (svc/accept! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/friendships/:id/decline" [id]
    (svc/decline! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/friendships/:id/block" [id]
    (svc/block! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
