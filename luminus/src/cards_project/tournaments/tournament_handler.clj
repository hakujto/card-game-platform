(ns cards_project.tournaments.tournament-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-tournament! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :description :format :tournament_type :status :max_players :entry_fee :prize_pool :start_time :end_time :is_online :location :rules_text :season_id :organizer_id :registrations_id :rounds_id :prizes_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO tournaments ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-tournament! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :description :format :tournament_type :status :max_players :entry_fee :prize_pool :start_time :end_time :is_online :location :rules_text :season_id :organizer_id :registrations_id :rounds_id :prizes_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE tournaments SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes tournaments-routes

  (GET "/api/tournaments" []
    (resp/response (queries/get-all-tournament db-spec)))

  (POST "/api/tournaments" {params :body}
    (let [new-id (insert-tournament! params)
          record  (or (queries/get-tournament-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/tournaments/:id" [id]
    (if-let [record (queries/get-tournament-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/tournaments/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-tournament! int-id params)
      (if-let [record (queries/get-tournament-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/tournaments/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-tournament! int-id params)
      (if-let [record (queries/get-tournament-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/tournaments/:id" [id]
    (queries/delete-tournament! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
