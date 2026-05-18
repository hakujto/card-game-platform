(ns cards_project.content.article-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.article-queries :as queries]
            [cards_project.content.article-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- article-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-article-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :view_count)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Article view count must not be negative"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-article-implies! [m]
  (let [errors (atom [])]
    (when (and (= (get m :status) "Published") (not (some? (get m :published_at))))
      (swap! errors conj "Published article must have a published_at timestamp"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-article! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:title :slug :body :excerpt :cover_image_url :status :article_type :view_count :published_at :author_id :featured_deck_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO articles ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-article! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:title :slug :body :excerpt :cover_image_url :status :article_type :view_count :published_at :author_id :featured_deck_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE articles SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes articles-routes

  (GET "/api/articles" []
    (resp/response (queries/get-all-article db-spec)))

  (POST "/api/articles" {params :body}
    (try
      (let [kw (article-kw-params params)]
        (validate-article-rules! kw)
        (validate-article-implies! kw)
        (let [new-id (insert-article! params)
              record  (or (queries/get-article-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/articles/:id" [id]
    (if-let [record (queries/get-article-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/articles/:id" [id :as {params :body}]
    (try
      (let [kw (article-kw-params params)]
        (validate-article-rules! kw)
        (validate-article-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-article! int-id params)
          (if-let [record (queries/get-article-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/articles/:id" [id :as {params :body}]
    (try
      (let [kw (article-kw-params params)]
        (validate-article-rules! kw)
        (validate-article-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-article! int-id params)
          (if-let [record (queries/get-article-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/articles/:id" [id]
    (queries/delete-article! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/articles/:id/publish" [id]
    (svc/publish! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/articles/:id/archive" [id]
    (svc/archive! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/articles/:id/view" [id]
    (svc/increment-view! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/articles/:id/reading-time" [id]
    (let [result (svc/reading-time-minutes! (Integer/parseInt id))]
      (resp/response {:result result})))
)
