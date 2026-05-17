(ns cards_project.cards.deck-sideboard-card-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.deck-sideboard-card-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-deck-sideboard-card! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:quantity :deck_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO deck_sideboard_cards ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-deck-sideboard-card! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:quantity :deck_id :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE deck_sideboard_cards SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes deck-sideboard-cards-routes

  (GET "/api/deck_sideboard_cards" []
    (resp/response (queries/get-all-deck-sideboard-card db-spec)))

  (POST "/api/deck_sideboard_cards" {params :body}
    (try
      (let [new-id (insert-deck-sideboard-card! params)
            record  (or (queries/get-deck-sideboard-card-by-id db-spec {:id new-id}) {:id new-id})]
        (-> (resp/response record) (resp/status 201)))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/deck_sideboard_cards/:id" [id]
    (if-let [record (queries/get-deck-sideboard-card-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/deck_sideboard_cards/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-deck-sideboard-card! int-id params)
        (if-let [record (queries/get-deck-sideboard-card-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/deck_sideboard_cards/:id" [id :as {params :body}]
    (try
      (let [int-id (Integer/parseInt id)]
        (update-deck-sideboard-card! int-id params)
        (if-let [record (queries/get-deck-sideboard-card-by-id db-spec {:id int-id})]
          (resp/response record)
          (-> (resp/response {:error "Not found"}) (resp/status 404))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/deck_sideboard_cards/:id" [id]
    (queries/delete-deck-sideboard-card! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))
)
