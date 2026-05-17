(ns cards_project.tournaments.tournament-registration-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-registration-queries :as queries]
            [cards_project.tournaments.tournament-registration-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- insert-tournament-registration! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :seed :final_standing :points_earned :registered_at :tournament_id :player_id :deck_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO tournament_registrations ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-tournament-registration! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:status :seed :final_standing :points_earned :registered_at :tournament_id :player_id :deck_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE tournament_registrations SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes tournament-registrations-routes

  (GET "/api/tournament_registrations" []
    (resp/response (queries/get-all-tournament-registration db-spec)))

  (POST "/api/tournament_registrations" {params :body}
    (try
      (let [new-id (insert-tournament-registration! params)
            record  (or (queries/get-tournament-registration-by-id db-spec {:id new-id}) {:id new-id})]
        (-> (resp/response record) (resp/status 201)))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/tournament_registrations/:id" [id]
    (if-let [record (queries/get-tournament-registration-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/tournament_registrations/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-tournament-registration! int-id params)
        (if-let [record (queries/get-tournament-registration-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/tournament_registrations/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-tournament-registration! int-id params)
        (if-let [record (queries/get-tournament-registration-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/tournament_registrations/:id" [id]
    (queries/delete-tournament-registration! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tournament_registrations/:id/withdraw" [id]
    (svc/withdraw! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tournament_registrations/:id/disqualify" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        reason (get params :reason)]
      (svc/disqualify! int-id reason)
      (-> (resp/response nil) (resp/status 204))))

  (POST "/api/tournament_registrations/:id/promote" [id]
    (svc/promote-from-waitlist! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
