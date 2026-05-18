(ns cards_project.cards.card-set-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.card-set-queries :as queries]
            [cards_project.cards.card-set-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- card-set-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-card-set-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :total_cards)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Card set must have at least one card"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-card-set-implies! [m]
  (let [errors (atom [])]
    (when (and (some? (get m :rotation_date)) (not (let [lhs (get m :rotation_date) rhs (get m :release_date)] (or (nil? lhs) (nil? rhs) (pos? (compare lhs rhs))))))
      (swap! errors conj "Rotation date must be after release date"))
    (when (and (true? (get m :is_rotated)) (not (some? (get m :rotation_date))))
      (swap! errors conj "Rotated set must have a rotation date"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-card-set! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :code :release_date :rotation_date :set_type :total_cards :is_rotated :description :logo_url}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO card_sets ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-card-set! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :code :release_date :rotation_date :set_type :total_cards :is_rotated :description :logo_url}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE card_sets SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes card-sets-routes

  (GET "/api/card_sets" []
    (resp/response (queries/get-all-card-set db-spec)))

  (POST "/api/card_sets" {params :body}
    (try
      (let [kw (card-set-kw-params params)]
        (validate-card-set-rules! kw)
        (validate-card-set-implies! kw)
        (let [new-id (insert-card-set! params)
              record  (or (queries/get-card-set-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/card_sets/:id" [id]
    (if-let [record (queries/get-card-set-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/card_sets/:id" [id :as {params :body}]
    (try
      (let [kw (card-set-kw-params params)]
        (validate-card-set-rules! kw)
        (validate-card-set-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-card-set! int-id params)
          (if-let [record (queries/get-card-set-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/card_sets/:id" [id :as {params :body}]
    (try
      (let [kw (card-set-kw-params params)]
        (validate-card-set-rules! kw)
        (validate-card-set-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-card-set! int-id params)
          (if-let [record (queries/get-card-set-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/card_sets/:id" [id]
    (queries/delete-card-set! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/card_sets/:id/standard-legal" [id]
    (let [result (svc/is-legal-in-standard! (Integer/parseInt id))]
      (resp/response {:result result})))

  (GET "/api/card_sets/:id/legal" [id]
    (let [result (svc/is-legal-in-format! (Integer/parseInt id))]
      (resp/response {:result result})))

  (GET "/api/card_sets/:id/rarity-count" [id]
    (let [result (svc/card-count-by-rarity! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/card_sets/:id/rotate" [id]
    (svc/rotate-out! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
