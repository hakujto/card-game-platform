(ns cards_project.content.draft-pick-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.draft-pick-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-draft-pick! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:pick_number :pack_number :picked_at :participant_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO draft_picks ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-draft-pick! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:pick_number :pack_number :picked_at :participant_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE draft_picks SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes draft-picks-routes

  (GET "/api/draft_picks" []
    (resp/response (queries/get-all-draft-pick db-spec)))

  (POST "/api/draft_picks" {params :body}
    (let [new-id (insert-draft-pick! params)
          record  (or (queries/get-draft-pick-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/draft_picks/:id" [id]
    (if-let [record (queries/get-draft-pick-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/draft_picks/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-draft-pick! int-id params)
      (if-let [record (queries/get-draft-pick-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/draft_picks/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-draft-pick! int-id params)
      (if-let [record (queries/get-draft-pick-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/draft_picks/:id" [id]
    (queries/delete-draft-pick! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
