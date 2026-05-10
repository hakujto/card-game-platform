(ns cards_project.content.article-comment-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.article-comment-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-article-comment! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:body :is_hidden :article_id :author_id :parent_comment_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO article_comments ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-article-comment! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:body :is_hidden :article_id :author_id :parent_comment_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE article_comments SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes article-comments-routes

  (GET "/api/article_comments" []
    (resp/response (queries/get-all-article-comment db-spec)))

  (POST "/api/article_comments" {params :body}
    (let [new-id (insert-article-comment! params)
          record  (or (queries/get-article-comment-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/article_comments/:id" [id]
    (if-let [record (queries/get-article-comment-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/article_comments/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-article-comment! int-id params)
      (if-let [record (queries/get-article-comment-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/article_comments/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-article-comment! int-id params)
      (if-let [record (queries/get-article-comment-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/article_comments/:id" [id]
    (queries/delete-article-comment! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
