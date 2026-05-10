(ns cards_project.tournaments.tournament-round-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-round-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-tournament-round! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:round_number :status :started_at :ended_at :time_limit_minutes :tournament_id :matches_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO tournament_rounds ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-tournament-round! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:round_number :status :started_at :ended_at :time_limit_minutes :tournament_id :matches_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE tournament_rounds SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes tournament-rounds-routes

  (GET "/api/tournament_rounds" []
    (resp/response (queries/get-all-tournament-round db-spec)))

  (POST "/api/tournament_rounds" {params :body}
    (let [new-id (insert-tournament-round! params)
          record  (or (queries/get-tournament-round-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/tournament_rounds/:id" [id]
    (if-let [record (queries/get-tournament-round-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/tournament_rounds/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-tournament-round! int-id params)
      (if-let [record (queries/get-tournament-round-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/tournament_rounds/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-tournament-round! int-id params)
      (if-let [record (queries/get-tournament-round-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/tournament_rounds/:id" [id]
    (queries/delete-tournament-round! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
