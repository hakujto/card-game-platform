(ns cards_project.marketplace.coupon-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.coupon-queries :as queries]
            [cards_project.marketplace.coupon-service :as svc]
            [cards_project.db :refer [db-spec]]))

(defn- coupon-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-coupon-rules! [m]
  (let [errors (atom [])]
    (when-not (let [lhs (get m :valid_until) rhs (get m :valid_from)] (or (nil? lhs) (nil? rhs) (pos? (compare lhs rhs))))
      (swap! errors conj "Coupon expiry must be after its start date"))
    (when-not (let [v (get m :discount_value)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Discount value must be greater than zero"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- validate-coupon-implies! [m]
  (let [errors (atom [])]
    (when (and (= (get m :discount_type) "Percent") (not (let [v (get m :discount_value)] (or (nil? v) (and (>= (->num v) 1) (<= (->num v) 100))))))
      (swap! errors conj "Percent discount must be between 1 and 100"))
    (when (and (some? (get m :max_uses)) (not (let [v (get m :uses_count)] (or (nil? v) (<= (->num v) (->num (get m :max_uses)))))))
      (swap! errors conj "Coupon uses count cannot exceed max_uses"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-coupon! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:code :discount_type :discount_value :min_order_value :max_uses :uses_count :valid_from :valid_until :is_active}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO coupons ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-coupon! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:code :discount_type :discount_value :min_order_value :max_uses :uses_count :valid_from :valid_until :is_active}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE coupons SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes coupons-routes

  (GET "/api/coupons" []
    (resp/response (queries/get-all-coupon db-spec)))

  (POST "/api/coupons" {params :body}
    (try
      (let [kw (coupon-kw-params params)]
        (validate-coupon-rules! kw)
        (validate-coupon-implies! kw)
        (let [new-id (insert-coupon! params)
              record  (or (queries/get-coupon-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/coupons/:id" [id]
    (if-let [record (queries/get-coupon-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/coupons/:id" [id :as {params :body}]
    (try
      (let [kw (coupon-kw-params params)]
        (validate-coupon-rules! kw)
        (validate-coupon-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-coupon! int-id params)
          (if-let [record (queries/get-coupon-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/coupons/:id" [id :as {params :body}]
    (try
      (let [kw (coupon-kw-params params)]
        (validate-coupon-rules! kw)
        (validate-coupon-implies! kw)
        (let [int-id (Integer/parseInt id)]
          (update-coupon! int-id params)
          (if-let [record (queries/get-coupon-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/coupons/:id" [id]
    (queries/delete-coupon! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))

  (GET "/api/coupons/:id/valid" [id]
    (let [result (svc/is-valid! (Integer/parseInt id))]
      (resp/response {:result result})))

  (GET "/api/coupons/:id/applicable" [id]
    (let [result (svc/is-applicable-to-order! (Integer/parseInt id))]
      (resp/response {:result result})))

  (POST "/api/coupons/:id/redeem" [id]
    (svc/redeem! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))

  (POST "/api/coupons/:id/deactivate" [id]
    (svc/deactivate! (Integer/parseInt id))
    (-> (resp/response nil) (resp/status 204)))
)
