(ns cards_project.tournaments.tournament-judge-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-judge-queries :as queries]
            [cards_project.tournaments.tournament-judge-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- insert-tournament-judge! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:role :tournament_id :player_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO tournament_judges ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-tournament-judge! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:role :tournament_id :player_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE tournament_judges SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes tournament-judges-routes

  (GET "/api/tournament_judges" []
    (resp/response (queries/get-all-tournament-judge db-spec)))

  (POST "/api/tournament_judges" {params :body}
    (try
      (let [new-id (insert-tournament-judge! params)
            record  (or (queries/get-tournament-judge-by-id db-spec {:id new-id}) {:id new-id})]
        (-> (resp/response record) (resp/status 201)))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/tournament_judges/:id" [id]
    (if-let [record (queries/get-tournament-judge-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/tournament_judges/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-tournament-judge! int-id params)
        (if-let [record (queries/get-tournament-judge-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/tournament_judges/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-tournament-judge! int-id params)
        (if-let [record (queries/get-tournament-judge-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/tournament_judges/:id" [id]
    (queries/delete-tournament-judge! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/tournament_judges/:id/promote" [id]
    (svc/promote-to-head! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (DELETE "/api/tournament_judges/:id" [id]
    (svc/remove! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
