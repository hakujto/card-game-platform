(ns cards_project.cards.card-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.card-queries :as queries]
            [cards_project.cards.card-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- card-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-card-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :mana_cost)] (or (nil? v) (and (>= (->num v) 0) (<= (->num v) 20))))
      (swap! errors conj "mana_cost must be between 0 and 20"))
    (when-not (let [v (get m :power_level)] (or (nil? v) (and (>= (->num v) 1) (<= (->num v) 10))))
      (swap! errors conj "power_level must be between 1 and 10"))
    (when-not (not (and (true? (get m :is_banned)) (true? (get m :is_restricted))))
      (swap! errors conj "Card cannot be both banned and restricted at the same time"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-card-implies! [m]
  (let [errors (atom [])]
    (when (and (= (get m :card_type) "Creature") (not (and (some? (get m :attack)) (some? (get m :defense)))))
      (swap! errors conj "Creature card must have attack and defense"))
    (when (and (= (get m :card_type) "Planeswalker") (not (some? (get m :loyalty))))
      (swap! errors conj "Planeswalker card must have loyalty"))
    (when (and (not= (get m :card_type) "Planeswalker") (not (nil? (get m :loyalty))))
      (swap! errors conj "Only Planeswalker cards can have loyalty"))
    (when (and (true? (get m :is_banned)) (not (= (get m :legal_formats) "message")))
      (swap! errors conj "banned_card_not_in_legal_formats"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-card! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :card_type :rarity :mana_cost :mana_colors :attack :defense :loyalty :description :flavor_text :image_url :artist_name :legal_formats :is_banned :is_restricted :power_level :set_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO cards ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-card! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:name :card_type :rarity :mana_cost :mana_colors :attack :defense :loyalty :description :flavor_text :image_url :artist_name :legal_formats :is_banned :is_restricted :power_level :set_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE cards SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes cards-routes

  (GET "/api/cards" []
    (resp/response (queries/get-all-card db-spec)))

  (POST "/api/cards" {params :body}
    (try
      (let [kw (card-kw-params params)]
        (validate-card-rules! kw)
        (validate-card-implies! kw)
        (let [new-id (insert-card! params)
              record  (or (queries/get-card-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/cards/:id" [id]
    (if-let [record (queries/get-card-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/cards/:id" [id :as {params :body}]
    (try
      (let [kw (card-kw-params params)]
        (validate-card-rules! kw)
        (validate-card-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-card! int-id params)
          (if-let [record (queries/get-card-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/cards/:id" [id :as {params :body}]
    (try
      (let [kw (card-kw-params params)]
        (validate-card-rules! kw)
        (validate-card-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-card! int-id params)
          (if-let [record (queries/get-card-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/cards/:id" [id]
    (queries/delete-card! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/cards/:id/ban" [id]
    (svc/ban! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/cards/:id/unban" [id]
    (svc/unban! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/cards/:id/restrict" [id]
    (svc/restrict! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/cards/:id/unrestrict" [id]
    (svc/unrestrict! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/cards/:id/value" [id]
    (let [result (svc/calculate-value! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/cards/:id/rarity-bonus" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        multiplier (get params :multiplier)
          result  (svc/apply-rarity-bonus! int-id multiplier)]
      (resp/response {:result result})))

  (GET "/api/cards/:id/legal" [id]
    (let [result (svc/is-legal-in-format! (Integer/parseInt id))]
      (resp/response {:result result})))
)
