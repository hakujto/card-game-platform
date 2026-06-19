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
        allowed  #{:status :reason :description :resolution :opened_at :resolved_at :transaction_id :opened_by_id :resolved_by_id}
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
        allowed  #{:status :reason :description :resolution :opened_at :resolved_at :transaction_id :opened_by_id :resolved_by_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE trade_disputes SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defn- apply-projection-trade-dispute [record]
  (when record
    (let [m (let [m record] (-> m (dissoc :opened_at) (assoc :opened_at (get m :opened_at))))] (-> m (dissoc :resolved_at) (assoc :resolved_at (get m :resolved_at))))))

(defroutes trade-disputes-routes

  (GET "/api/trade_disputes" []
    (resp/response (map apply-projection-trade-dispute (queries/get-all-trade-dispute db-spec))))

  (POST "/api/trade_disputes" {params :body}
    (try
      (let [kw (trade-dispute-kw-params params)]
        (validate-trade-dispute-implies! kw)
        (let [new-id (insert-trade-dispute! params)
              record  (or (queries/get-trade-dispute-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response (apply-projection-trade-dispute record)) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/trade_disputes/:id" [id]
    (if-let [record (queries/get-trade-dispute-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response (apply-projection-trade-dispute record))
      (-> (resp/response {:error "Not found"}) (resp/status 404))))


  (POST "/api/trade_disputes/:id/escalate" [id]
    (svc/escalate! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/trade_disputes/:id/resolve" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)
        resolution-text (get params :resolution-text)]
      (svc/resolve! int-id resolution-text)
      (-> (resp/response nil) (resp/status 204))))

  (POST "/api/trade_disputes/:id/close" [id]
    (svc/close-resolved! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/trade_disputes/:id/review" [id]
    (svc/review! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (PATCH "/api/trade_disputes/:id/transitions/open-to-underreview" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Admin" "Moderator"} user-role))
        (-> (resp/response {:error "Insufficient role for transition Open -> UnderReview"}) (resp/status 403))
        (try
          (let [record (svc/transition-open-to-under-review! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/trade_disputes/:id/transitions/underreview-to-resolved" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Admin" "Moderator"} user-role))
        (-> (resp/response {:error "Insufficient role for transition UnderReview -> Resolved"}) (resp/status 403))
        (try
          (let [record (svc/transition-under-review-to-resolved! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/trade_disputes/:id/transitions/underreview-to-escalated" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Admin"} user-role))
        (-> (resp/response {:error "Insufficient role for transition UnderReview -> Escalated"}) (resp/status 403))
        (try
          (let [record (svc/transition-under-review-to-escalated! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/trade_disputes/:id/transitions/escalated-to-resolved" [id :as request]
    (let [user-role (get-in request [:headers "x-user-role"])]
      (if (not (contains? #{"Admin"} user-role))
        (-> (resp/response {:error "Insufficient role for transition Escalated -> Resolved"}) (resp/status 403))
        (try
          (let [record (svc/transition-escalated-to-resolved! (Integer/parseInt id))]
            (resp/response record))
          (catch clojure.lang.ExceptionInfo e
            (let [status (get (ex-data e) :status 500)]
              (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
          (catch Exception e
            (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))))

  (PATCH "/api/trade_disputes/:id/transitions/resolved-to-open" [id]
    (try
      (let [record (svc/transition-resolved-to-open! (Integer/parseInt id))]
        (resp/response record))
      (catch clojure.lang.ExceptionInfo e
        (let [status (get (ex-data e) :status 500)]
          (-> (resp/response {:error (.getMessage e)}) (resp/status status))))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))
)
