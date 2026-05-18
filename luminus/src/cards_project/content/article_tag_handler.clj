(ns cards_project.content.article-tag-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.article-tag-queries :as queries]
            [cards_project.content.article-tag-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- insert-article-tag! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
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
    (try
      (let [new-id (insert-article-tag! params)
            record  (or (queries/get-article-tag-by-id db-spec {:id new-id}) {:id new-id})]
        (-> (resp/response record) (resp/status 201)))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/article_tags/:id" [id]
    (if-let [record (queries/get-article-tag-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/article_tags/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-article-tag! int-id params)
        (if-let [record (queries/get-article-tag-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/article_tags/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-article-tag! int-id params)
        (if-let [record (queries/get-article-tag-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/article_tags/:id" [id]
    (queries/delete-article-tag! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (PATCH "/api/article_tags/:id/rename" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        new-name (get params :new-name)]
      (svc/rename! int-id new-name)
      (-> (resp/response nil) (resp/status 204))))

  (GET "/api/article_tags/:id/article-count" [id]
    (let [result (svc/article-count! (Integer/parseInt id))]
      (resp/response {:result result})))
)
