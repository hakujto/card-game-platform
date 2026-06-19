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
        allowed  #{:title :stream_url :status :platform :language :is_official :viewer_count_peak :scheduled_start :actual_start :ended_at :vod_url :tournament_id :streamer_id}
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
        allowed  #{:title :stream_url :status :platform :language :is_official :viewer_count_peak :scheduled_start :actual_start :ended_at :vod_url :tournament_id :streamer_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE streams SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defn- apply-projection-stream [record]
  (when record
    (let [m (let [m (let [m record] (-> m (dissoc :scheduled_start) (assoc :scheduled_start (get m :scheduled_start))))] (-> m (dissoc :actual_start) (assoc :actual_start (get m :actual_start))))] (-> m (dissoc :ended_at) (assoc :ended_at (get m :ended_at))))))

(defroutes streams-routes

  (GET "/api/streams" {params :query-params}
    (let [q (or (get params "q") "")]
      (resp/response (map apply-projection-stream (filter #(or (empty? q) (or (clojure.string/includes? (str (get % :title "")) q))) (queries/get-all-stream db-spec))))))

  (POST "/api/streams" {params :body}
    (try
      (let [kw (stream-kw-params params)]
        (validate-stream-rules! kw)
        (validate-stream-implies! kw)
        (let [new-id (insert-stream! params)
              record  (or (queries/get-stream-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response (apply-projection-stream record)) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/streams/:id" [id]
    (if-let [record (queries/get-stream-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response (apply-projection-stream record))
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/streams/:id" [id :as {params :body :as req}]
    (try
      (let [kw (stream-kw-params params)]
        (validate-stream-rules! kw)
        (validate-stream-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-stream! int-id params)
          (if-let [record (queries/get-stream-by-id db-spec {:id int-id})]
            (resp/response (apply-projection-stream record))
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/streams/:id" [id :as {params :body :as req}]
    (try
      (let [kw (stream-kw-params params)]
        (validate-stream-rules! kw)
        (validate-stream-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-stream! int-id params)
          (if-let [record (queries/get-stream-by-id db-spec {:id int-id})]
            (resp/response (apply-projection-stream record))
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))


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

  (PATCH "/api/streams/:id/transitions/scheduled-to-live" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Streamer" "Admin"} user-role))
        (-> (resp/response {:error "Insufficient role for transition Scheduled -> Live"}) (resp/status 403))
        (try
          (let [record (svc/transition-scheduled-to-live! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/streams/:id/transitions/live-to-ended" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Streamer" "Admin"} user-role))
        (-> (resp/response {:error "Insufficient role for transition Live -> Ended"}) (resp/status 403))
        (try
          (let [record (svc/transition-live-to-ended! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/streams/:id/transitions/ended-to-live" [id]
    (try
      (let [record (svc/transition-ended-to-live! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))
)
