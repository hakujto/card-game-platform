(ns cards_project.cards.deck-tag-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.deck-tag-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-deck-tag! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :color}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO deck_tags ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-deck-tag! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :color}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE deck_tags SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes deck-tags-routes

  (GET "/api/deck_tags" []
    (resp/response (queries/get-all-deck-tag db-spec)))

  (POST "/api/deck_tags" {params :body}
    (let [new-id (insert-deck-tag! params)
          record  (or (queries/get-deck-tag-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/deck_tags/:id" [id]
    (if-let [record (queries/get-deck-tag-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/deck_tags/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-deck-tag! int-id params)
      (if-let [record (queries/get-deck-tag-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/deck_tags/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-deck-tag! int-id params)
      (if-let [record (queries/get-deck-tag-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/deck_tags/:id" [id]
    (queries/delete-deck-tag! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
