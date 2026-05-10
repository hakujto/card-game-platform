(ns cards_project.content.article-tag-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.article-tag-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-article-tag! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :slug}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO article_tags ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-article-tag! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :slug}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE article_tags SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes article-tags-routes

  (GET "/api/article_tags" []
    (resp/response (queries/get-all-article-tag db-spec)))

  (POST "/api/article_tags" {params :body}
    (let [new-id (insert-article-tag! params)
          record  (or (queries/get-article-tag-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/article_tags/:id" [id]
    (if-let [record (queries/get-article-tag-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/article_tags/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-article-tag! int-id params)
      (if-let [record (queries/get-article-tag-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/article_tags/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-article-tag! int-id params)
      (if-let [record (queries/get-article-tag-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/article_tags/:id" [id]
    (queries/delete-article-tag! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
