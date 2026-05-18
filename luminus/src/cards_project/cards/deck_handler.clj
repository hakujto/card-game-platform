(ns cards_project.cards.deck-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.deck-queries :as queries]
            [cards_project.cards.deck-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- deck-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-deck-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :wins)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Deck wins count must not be negative"))
    (when-not (let [v (get m :losses)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Deck losses count must not be negative"))
    (when-not (let [v (get m :draws)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Deck draws count must not be negative"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-deck-implies! [m]
  (let [errors (atom [])]
    (when (and (true? (get m :is_tournament_legal)) (not (true? (get m :is_public))))
      (swap! errors conj "Tournament-legal deck must be made public"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-deck! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :description :format :is_public :is_tournament_legal :archetype :wins :losses :draws :player_id}
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :description :format :is_public :is_tournament_legal :archetype :wins :losses :draws :player_id}
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
    (try
      (let [kw (deck-kw-params params)]
        (validate-deck-rules! kw)
        (validate-deck-implies! kw)
        (let [new-id (insert-deck! params)
              record  (or (queries/get-deck-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/decks/:id" [id]
    (if-let [record (queries/get-deck-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/decks/:id" [id :as {params :body}]
    (try
      (let [kw (deck-kw-params params)]
        (validate-deck-rules! kw)
        (validate-deck-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-deck! int-id params)
          (if-let [record (queries/get-deck-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/decks/:id" [id :as {params :body}]
    (try
      (let [kw (deck-kw-params params)]
        (validate-deck-rules! kw)
        (validate-deck-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-deck! int-id params)
          (if-let [record (queries/get-deck-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/decks/:id" [id]
    (queries/delete-deck! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/decks/:id/validate" [id]
    (let [result (svc/validate-size! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/decks/:id/cards" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        card-id (get params :card-id)
        quantity (get params :quantity)]
      (svc/add-card! int-id card-id quantity)
      (-> (resp/response nil) (resp/status 204))))

  (DELETE "/api/decks/:id/cards/:card_id" [id card_id]
    (svc/remove-card! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/decks/:id/win-rate" [id]
    (let [result (svc/win-rate! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/decks/:id/clone" [id]
    (let [result (svc/clone! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/decks/:id/publish" [id]
    (svc/publish! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/decks/:id/unpublish" [id]
    (svc/unpublish! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/decks/:id/certify" [id]
    (let [result (svc/certify-tournament-legal! (Integer/parseInt id))]
      (resp/response {:result result})))
)
