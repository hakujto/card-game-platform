(ns cards_project.marketplace.card-price-history-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.card-price-history-queries :as queries]
            [cards_project.marketplace.card-price-history-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- card-price-history-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-card-price-history-rules! [m]
  (let [errors (atom [])]
    (when-not (and (let [v (get m :min_price)] (or (nil? v) (<= (->num v) (->num (get m :avg_price))))) (let [v (get m :avg_price)] (or (nil? v) (<= (->num v) (->num (get m :max_price))))))
      (swap! errors conj "min_price <= avg_price <= max_price must hold"))
    (when-not (let [v (get m :volume)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Price history volume must not be negative"))
    (when-not (let [v (get m :min_price)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Prices must not be negative"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-card-price-history! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:price_date :avg_price :min_price :max_price :volume :foil :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO card_price_histories ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-card-price-history! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:price_date :avg_price :min_price :max_price :volume :foil :card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE card_price_histories SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes card-price-histories-routes

  (GET "/api/card_price_histories" []
    (resp/response (queries/get-all-card-price-history db-spec)))

  (POST "/api/card_price_histories" {params :body}
    (try
      (let [kw (card-price-history-kw-params params)]
        (validate-card-price-history-rules! kw)
        (let [new-id (insert-card-price-history! params)
              record  (or (queries/get-card-price-history-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/card_price_histories/:id" [id]
    (if-let [record (queries/get-card-price-history-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/card_price_histories/:id" [id :as {params :body}]
    (try
      (let [kw (card-price-history-kw-params params)]
        (validate-card-price-history-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-card-price-history! int-id params)
          (if-let [record (queries/get-card-price-history-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/card_price_histories/:id" [id :as {params :body}]
    (try
      (let [kw (card-price-history-kw-params params)]
        (validate-card-price-history-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-card-price-history! int-id params)
          (if-let [record (queries/get-card-price-history-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/card_price_histories/:id" [id]
    (queries/delete-card-price-history! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/card_price_histories/:id/change" [id]
    (let [result (svc/price-change-percent! (Integer/parseInt id))]
      (resp/response {:result result})))

  (GET "/api/card_price_histories/:id/spike" [id]
    (let [result (svc/is-price-spike! (Integer/parseInt id))]
      (resp/response {:result result})))
)
