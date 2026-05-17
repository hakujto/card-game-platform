(ns cards_project.tournaments.season-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.season-queries :as queries]
            [cards_project.tournaments.season-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- season-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-season-rules! [m]
  (let [errors (atom [])]
    (when-not (let [lhs (get m :end_date) rhs (get m :start_date)] (or (nil? lhs) (nil? rhs) (pos? (compare lhs rhs))))
      (swap! errors conj "Season end date must be after start date"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-season! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :start_date :end_date :format :is_active :reward_description}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO seasons ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-season! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :start_date :end_date :format :is_active :reward_description}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE seasons SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes seasons-routes

  (GET "/api/seasons" []
    (resp/response (queries/get-all-season db-spec)))

  (POST "/api/seasons" {params :body}
    (try
      (let [kw (season-kw-params params)]
        (validate-season-rules! kw)
        (let [new-id (insert-season! params)
              record  (or (queries/get-season-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/seasons/:id" [id]
    (if-let [record (queries/get-season-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/seasons/:id" [id :as {params :body}]
    (try
      (let [kw (season-kw-params params)]
        (validate-season-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-season! int-id params)
          (if-let [record (queries/get-season-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/seasons/:id" [id :as {params :body}]
    (try
      (let [kw (season-kw-params params)]
        (validate-season-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-season! int-id params)
          (if-let [record (queries/get-season-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/seasons/:id" [id]
    (queries/delete-season! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/seasons/:id/activate" [id]
    (svc/activate! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/seasons/:id/deactivate" [id]
    (svc/deactivate! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/seasons/:id/finalize" [id]
    (svc/finalize-rewards! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
