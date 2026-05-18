(ns cards_project.players.achievement-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.achievement-queries :as queries]
            [cards_project.players.achievement-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- achievement-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-achievement-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :points)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Achievement must award at least one point"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-achievement! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :description :icon_url :points :rarity :is_hidden}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO achievements ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-achievement! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :description :icon_url :points :rarity :is_hidden}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE achievements SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes achievements-routes

  (GET "/api/achievements" []
    (resp/response (queries/get-all-achievement db-spec)))

  (POST "/api/achievements" {params :body}
    (try
      (let [kw (achievement-kw-params params)]
        (validate-achievement-rules! kw)
        (let [new-id (insert-achievement! params)
              record  (or (queries/get-achievement-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/achievements/:id" [id]
    (if-let [record (queries/get-achievement-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/achievements/:id" [id :as {params :body}]
    (try
      (let [kw (achievement-kw-params params)]
        (validate-achievement-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-achievement! int-id params)
          (if-let [record (queries/get-achievement-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/achievements/:id" [id :as {params :body}]
    (try
      (let [kw (achievement-kw-params params)]
        (validate-achievement-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-achievement! int-id params)
          (if-let [record (queries/get-achievement-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/achievements/:id" [id]
    (queries/delete-achievement! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/achievements/:id/point-value" [id]
    (let [result (svc/point-value! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/achievements/:id/reveal" [id]
    (svc/reveal! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
