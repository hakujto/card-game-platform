(ns cards_project.content.stream-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.stream-queries :as queries]
            [cards_project.content.stream-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- stream-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-stream-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :viewer_count_peak)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Peak viewer count must not be negative"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-stream-implies! [m]
  (let [errors (atom [])]
    (when (and (some? (get m :actual_start)) (not (= (get m :status) "Live")))
      (swap! errors conj "actual_start_requires_live_or_ended"))
    (when (and (some? (get m :ended_at)) (not (= (get m :status) "Ended")))
      (swap! errors conj "ended_at can only be set when stream status is Ended"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-stream! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:title :stream_url :platform :status :viewer_count_peak :scheduled_start :actual_start :ended_at :vod_url :tournament_id :streamer_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO streams ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-stream! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:title :stream_url :platform :status :viewer_count_peak :scheduled_start :actual_start :ended_at :vod_url :tournament_id :streamer_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE streams SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes streams-routes

  (GET "/api/streams" []
    (resp/response (queries/get-all-stream db-spec)))

  (POST "/api/streams" {params :body}
    (try
      (let [kw (stream-kw-params params)]
        (validate-stream-rules! kw)
        (validate-stream-implies! kw)
        (let [new-id (insert-stream! params)
              record  (or (queries/get-stream-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/streams/:id" [id]
    (if-let [record (queries/get-stream-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/streams/:id" [id :as {params :body}]
    (try
      (let [kw (stream-kw-params params)]
        (validate-stream-rules! kw)
        (validate-stream-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-stream! int-id params)
          (if-let [record (queries/get-stream-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/streams/:id" [id :as {params :body}]
    (try
      (let [kw (stream-kw-params params)]
        (validate-stream-rules! kw)
        (validate-stream-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-stream! int-id params)
          (if-let [record (queries/get-stream-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/streams/:id" [id]
    (queries/delete-stream! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/streams/:id/live" [id]
    (svc/go-live! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/streams/:id/end" [id]
    (svc/end! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (PATCH "/api/streams/:id/viewers" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        count (get params :count)]
      (svc/update-viewer-peak! int-id count)
      (-> (resp/response nil) (resp/status 204))))

  (GET "/api/streams/:id/duration" [id]
    (let [result (svc/duration-minutes! (Integer/parseInt id))]
      (resp/response {:result result})))
)
