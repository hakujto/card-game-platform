(ns cards_project.content.article-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.article-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-article! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:title :slug :body :excerpt :cover_image_url :status :article_type :view_count :published_at :author_id :featured_deck_id :comments_id}
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:title :slug :body :excerpt :cover_image_url :status :article_type :view_count :published_at :author_id :featured_deck_id :comments_id}
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
    (let [new-id (insert-article! params)
          record  (or (queries/get-article-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/articles/:id" [id]
    (if-let [record (queries/get-article-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/articles/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-article! int-id params)
      (if-let [record (queries/get-article-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/articles/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-article! int-id params)
      (if-let [record (queries/get-article-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/articles/:id" [id]
    (queries/delete-article! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
