(ns cards_project.marketplace.trade-dispute-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.trade-dispute-queries :as queries]
            [cards_project.marketplace.trade-dispute-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- trade-dispute-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- validate-trade-dispute-implies! [m]
  (let [errors (atom [])]
    (when (and (some? (get m :resolved_at)) (not (= (get m :status) "Resolved")))
      (swap! errors conj "resolved_at_requires_terminal_status"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-trade-dispute! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:reason :description :status :resolution :opened_at :resolved_at :transaction_id :opened_by_id :resolved_by_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO trade_disputes ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-trade-dispute! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:reason :description :status :resolution :opened_at :resolved_at :transaction_id :opened_by_id :resolved_by_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE trade_disputes SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes trade-disputes-routes

  (GET "/api/trade_disputes" []
    (resp/response (queries/get-all-trade-dispute db-spec)))

  (POST "/api/trade_disputes" {params :body}
    (try
      (let [kw (trade-dispute-kw-params params)]
        (validate-trade-dispute-implies! kw)
        (let [new-id (insert-trade-dispute! params)
              record  (or (queries/get-trade-dispute-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/trade_disputes/:id" [id]
    (if-let [record (queries/get-trade-dispute-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/trade_disputes/:id" [id :as {params :body}]
    (try
      (let [kw (trade-dispute-kw-params params)]
        (validate-trade-dispute-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-trade-dispute! int-id params)
          (if-let [record (queries/get-trade-dispute-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/trade_disputes/:id" [id :as {params :body}]
    (try
      (let [kw (trade-dispute-kw-params params)]
        (validate-trade-dispute-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-trade-dispute! int-id params)
          (if-let [record (queries/get-trade-dispute-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/trade_disputes/:id" [id]
    (queries/delete-trade-dispute! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/trade_disputes/:id/escalate" [id]
    (svc/escalate! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/trade_disputes/:id/resolve" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        resolution-text (get params :resolution-text)]
      (svc/resolve! int-id resolution-text)
      (-> (resp/response nil) (resp/status 204))))

  (POST "/api/trade_disputes/:id/review" [id]
    (svc/review! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
