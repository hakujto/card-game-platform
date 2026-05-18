(ns cards_project.content.draft-pick-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.draft-pick-queries :as queries]
            [cards_project.content.draft-pick-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- draft-pick-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-draft-pick-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :pick_number)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Pick number must be greater than zero"))
    (when-not (let [v (get m :pack_number)] (or (nil? v) (and (>= (->num v) 1) (<= (->num v) 3))))
      (swap! errors conj "Pack number must be between 1 and 3"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-draft-pick! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:pick_number :pack_number :picked_at :participant_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO draft_picks ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-draft-pick! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:pick_number :pack_number :picked_at :participant_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE draft_picks SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes draft-picks-routes

  (GET "/api/draft_picks" []
    (resp/response (queries/get-all-draft-pick db-spec)))

  (POST "/api/draft_picks" {params :body}
    (try
      (let [kw (draft-pick-kw-params params)]
        (validate-draft-pick-rules! kw)
        (let [new-id (insert-draft-pick! params)
              record  (or (queries/get-draft-pick-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/draft_picks/:id" [id]
    (if-let [record (queries/get-draft-pick-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/draft_picks/:id" [id :as {params :body}]
    (try
      (let [kw (draft-pick-kw-params params)]
        (validate-draft-pick-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-draft-pick! int-id params)
          (if-let [record (queries/get-draft-pick-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/draft_picks/:id" [id :as {params :body}]
    (try
      (let [kw (draft-pick-kw-params params)]
        (validate-draft-pick-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-draft-pick! int-id params)
          (if-let [record (queries/get-draft-pick-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/draft_picks/:id" [id]
    (queries/delete-draft-pick! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/draft_picks/:id/first-pick" [id]
    (let [result (svc/is-first-pick! (Integer/parseInt id))]
      (resp/response {:result result})))
)
