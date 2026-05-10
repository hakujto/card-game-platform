(ns cards_project.cards.deck-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.deck-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-deck! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :description :format :is_public :is_tournament_legal :archetype :wins :losses :player_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO decks ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-deck! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :description :format :is_public :is_tournament_legal :archetype :wins :losses :player_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE decks SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes decks-routes

  (GET "/api/decks" []
    (resp/response (queries/get-all-deck db-spec)))

  (POST "/api/decks" {params :body}
    (let [new-id (insert-deck! params)
          record  (or (queries/get-deck-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/decks/:id" [id]
    (if-let [record (queries/get-deck-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/decks/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-deck! int-id params)
      (if-let [record (queries/get-deck-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/decks/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-deck! int-id params)
      (if-let [record (queries/get-deck-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/decks/:id" [id]
    (queries/delete-deck! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
