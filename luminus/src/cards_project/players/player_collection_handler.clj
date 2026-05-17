(ns cards_project.players.player-collection-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-collection-queries :as queries]
            [cards_project.players.player-collection-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- insert-player-collection! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:quantity :foil :condition :acquired_at :acquired_via :player_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO player_collections ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-player-collection! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:quantity :foil :condition :acquired_at :acquired_via :player_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE player_collections SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes player-collections-routes

  (GET "/api/player_collections" []
    (resp/response (queries/get-all-player-collection db-spec)))

  (POST "/api/player_collections" {params :body}
    (try
      (let [new-id (insert-player-collection! params)
            record  (or (queries/get-player-collection-by-id db-spec {:id new-id}) {:id new-id})]
        (-> (resp/response record) (resp/status 201)))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/player_collections/:id" [id]
    (if-let [record (queries/get-player-collection-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/player_collections/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-player-collection! int-id params)
        (if-let [record (queries/get-player-collection-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/player_collections/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-player-collection! int-id params)
        (if-let [record (queries/get-player-collection-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/player_collections/:id" [id]
    (queries/delete-player-collection! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/player_collections/:id/value" [id]
    (let [result (svc/estimated-value! (Integer/parseInt id))]
      (resp/response {:result result})))
)
