(ns cards_project.cards.deck-tag-assignment-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.deck-tag-assignment-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-deck-tag-assignment! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:deck_id :tag_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO deck_tag_assignments ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-deck-tag-assignment! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:deck_id :tag_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE deck_tag_assignments SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes deck-tag-assignments-routes

  (GET "/api/deck_tag_assignments" []
    (resp/response (queries/get-all-deck-tag-assignment db-spec)))

  (POST "/api/deck_tag_assignments" {params :body}
    (let [new-id (insert-deck-tag-assignment! params)
          record  (or (queries/get-deck-tag-assignment-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/deck_tag_assignments/:id" [id]
    (if-let [record (queries/get-deck-tag-assignment-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/deck_tag_assignments/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-deck-tag-assignment! int-id params)
      (if-let [record (queries/get-deck-tag-assignment-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/deck_tag_assignments/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-deck-tag-assignment! int-id params)
      (if-let [record (queries/get-deck-tag-assignment-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/deck_tag_assignments/:id" [id]
    (queries/delete-deck-tag-assignment! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
