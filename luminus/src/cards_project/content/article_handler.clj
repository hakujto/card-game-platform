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
    (when-not (let [v (get m :likes_count)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Article likes count must not be negative"))
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
        allowed  #{:title :slug :body :excerpt :cover_image_url :status :article_type :language :view_count :likes_count :is_featured :published_at :author_id :featured_deck_id}
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
        allowed  #{:title :slug :body :excerpt :cover_image_url :status :article_type :language :view_count :likes_count :is_featured :published_at :author_id :featured_deck_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE articles SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defn- apply-projection-article [record]
  (when record
    (let [m (let [m (let [m record] (-> m (dissoc :created_at) (assoc :created_at (get m :created_at))))] (-> m (dissoc :updated_at) (assoc :updated_at (get m :updated_at))))] (-> m (dissoc :published_at) (assoc :published_at (get m :published_at))))))

(defroutes articles-routes

  (GET "/api/articles" {params :query-params}
    (let [q (or (get params "q") "")]
      (resp/response (map apply-projection-article (filter #(or (empty? q) (or (clojure.string/includes? (str (get % :title "")) q) (clojure.string/includes? (str (get % :excerpt "")) q))) (queries/get-all-article db-spec))))))

  (POST "/api/articles" {params :body}
    (try
      (let [kw (article-kw-params params)]
        (validate-article-rules! kw)
        (validate-article-implies! kw)
        (let [new-id (insert-article! params)
              record  (or (queries/get-article-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response (apply-projection-article record)) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/articles/:id" [id]
    (if-let [record (queries/get-article-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response (apply-projection-article record))
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/articles/:id" [id :as {params :body :as req}]
    (try
      (let [kw (article-kw-params params)]
        (validate-article-rules! kw)
        (validate-article-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-article! int-id params)
          (if-let [record (queries/get-article-by-id db-spec {:id int-id})]
            (resp/response (apply-projection-article record))
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/articles/:id" [id :as {params :body :as req}]
    (try
      (let [kw (article-kw-params params)]
        (validate-article-rules! kw)
        (validate-article-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-article! int-id params)
          (if-let [record (queries/get-article-by-id db-spec {:id int-id})]
            (resp/response (apply-projection-article record))
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))


  (POST "/api/articles/:id/publish" [id]
    (svc/publish! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/articles/:id/archive" [id]
    (svc/archive! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/articles/:id/view" [id]
    (svc/increment-view! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/articles/:id/like" [id]
    (svc/like! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (DELETE "/api/articles/:id/like" [id]
    (svc/unlike! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/articles/:id/reading-time" [id]
    (let [result (svc/reading-time-minutes! (Integer/parseInt id))]
      (resp/response {:result result})))

  (PATCH "/api/articles/:id/transitions/draft-to-published" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Editor" "Admin"} user-role))
        (-> (resp/response {:error "Insufficient role for transition Draft -> Published"}) (resp/status 403))
        (try
          (let [record (svc/transition-draft-to-published! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/articles/:id/transitions/published-to-archived" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Editor" "Admin"} user-role))
        (-> (resp/response {:error "Insufficient role for transition Published -> Archived"}) (resp/status 403))
        (try
          (let [record (svc/transition-published-to-archived! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/articles/:id/transitions/archived-to-draft" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Admin"} user-role))
        (-> (resp/response {:error "Insufficient role for transition Archived -> Draft"}) (resp/status 403))
        (try
          (let [record (svc/transition-archived-to-draft! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/articles/:id/transitions/published-to-draft" [id]
    (try
      (let [record (svc/transition-published-to-draft! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))
)
