(ns cards_project.tournaments.tournament-prize-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-prize-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- tournament-prize-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-tournament-prize-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :placement_to)] (or (nil? v) (>= (->num v) (->num (get m :placement_from)))))
      (swap! errors conj "placement_to must be greater than or equal to placement_from"))
    (when-not (let [v (get m :placement_from)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "placement_from must be greater than zero"))
    (when-not (let [v (get m :amount)] (or (nil? v) (>= (->num v) 0)))
      (swap! errors conj "Prize amount must not be negative"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-tournament-prize! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:placement_from :placement_to :prize_type :amount :description :packs_count :season_points :tournament_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO tournament_prizes ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-tournament-prize! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:placement_from :placement_to :prize_type :amount :description :packs_count :season_points :tournament_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE tournament_prizes SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes tournament-prizes-routes

  (GET "/api/tournament_prizes" []
    (resp/response (queries/get-all-tournament-prize db-spec)))

  (POST "/api/tournament_prizes" {params :body}
    (try
      (let [kw (tournament-prize-kw-params params)]
        (validate-tournament-prize-rules! kw)
        (let [new-id (insert-tournament-prize! params)
              record  (or (queries/get-tournament-prize-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/tournament_prizes/:id" [id]
    (if-let [record (queries/get-tournament-prize-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/tournament_prizes/:id" [id :as {params :body}]
    (try
      (let [kw (tournament-prize-kw-params params)]
        (validate-tournament-prize-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-tournament-prize! int-id params)
          (if-let [record (queries/get-tournament-prize-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/tournament_prizes/:id" [id :as {params :body}]
    (try
      (let [kw (tournament-prize-kw-params params)]
        (validate-tournament-prize-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-tournament-prize! int-id params)
          (if-let [record (queries/get-tournament-prize-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/tournament_prizes/:id" [id]
    (queries/delete-tournament-prize! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))
)
