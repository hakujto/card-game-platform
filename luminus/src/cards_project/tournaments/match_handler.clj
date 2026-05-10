(ns cards_project.tournaments.match-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.match-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-match! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:table_number :status :player1_wins :player2_wins :started_at :ended_at :result_notes :round_id :player1_id :player2_id :games_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO matches ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-match! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:table_number :status :player1_wins :player2_wins :started_at :ended_at :result_notes :round_id :player1_id :player2_id :games_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE matches SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes matches-routes

  (GET "/api/matches" []
    (resp/response (queries/get-all-match db-spec)))

  (POST "/api/matches" {params :body}
    (let [new-id (insert-match! params)
          record  (or (queries/get-match-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/matches/:id" [id]
    (if-let [record (queries/get-match-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/matches/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-match! int-id params)
      (if-let [record (queries/get-match-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/matches/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-match! int-id params)
      (if-let [record (queries/get-match-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/matches/:id" [id]
    (queries/delete-match! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
