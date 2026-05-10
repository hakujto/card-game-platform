(ns cards_project.content.stream-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.stream-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-stream! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
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
    (let [new-id (insert-stream! params)
          record  (or (queries/get-stream-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/streams/:id" [id]
    (if-let [record (queries/get-stream-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/streams/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-stream! int-id params)
      (if-let [record (queries/get-stream-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/streams/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-stream! int-id params)
      (if-let [record (queries/get-stream-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/streams/:id" [id]
    (queries/delete-stream! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
