(ns cards_project.players.crafting-recipe-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.crafting-recipe-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- crafting-recipe-kw-params [params]
  (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params)))

(defn- ->num [v] (when (some? v) (if (string? v) (Double/parseDouble v) (double v))))

(defn- validate-crafting-recipe-rules! [m]
  (let [errors (atom [])]
    (when-not (let [v (get m :dust_cost)] (or (nil? v) (> (->num v) 0)))
      (swap! errors conj "Crafting recipe must have a dust cost greater than zero"))
    (when (seq @errors)
      (throw (ex-info "Validation failed" {:errors @errors :status 422})))))

(defn- insert-crafting-recipe! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:dust_cost :is_available :result_card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "INSERT INTO crafting_recipes ("
                     (clojure.string/join ", " cols)
                     ") VALUES ("
                     (clojure.string/join ", " (repeat (count cols) "?"))
                     ")")]
    (with-open [conn (jdbc/get-connection db-spec)]
      (jdbc/execute-one! conn (into [sql] vals))
      (-> (jdbc/execute-one! conn ["SELECT last_insert_rowid() AS id"]
                             {:builder-fn rs/as-unqualified-lower-maps})
          :id))))

(defn- update-crafting-recipe! [id params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (clojure.string/replace (name k) "-" "_")) v]) params))
        allowed  #{:dust_cost :is_available :result_card_id}
        pairs    (filter (fn [[k _]] (allowed k)) kw-params)
        cols     (map #(name (first %)) pairs)
        vals     (map second pairs)
        sql      (str "UPDATE crafting_recipes SET "
                     (clojure.string/join ", " (map #(str % " = ?") cols))
                     " WHERE id = ?")]
    (jdbc/execute-one! db-spec (into [sql] (conj (vec vals) id)))))

(defroutes crafting-recipes-routes

  (GET "/api/crafting_recipes" []
    (resp/response (queries/get-all-crafting-recipe db-spec)))

  (POST "/api/crafting_recipes" {params :body}
    (try
      (let [kw (crafting-recipe-kw-params params)]
        (validate-crafting-recipe-rules! kw)
        (let [new-id (insert-crafting-recipe! params)
              record  (or (queries/get-crafting-recipe-by-id db-spec {:id new-id}) {:id new-id})]
          (-> (resp/response record) (resp/status 201))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (GET "/api/crafting_recipes/:id" [id]
    (if-let [record (queries/get-crafting-recipe-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/crafting_recipes/:id" [id :as {params :body}]
    (try
      (let [kw (crafting-recipe-kw-params params)]
        (validate-crafting-recipe-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-crafting-recipe! int-id params)
          (if-let [record (queries/get-crafting-recipe-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (PATCH "/api/crafting_recipes/:id" [id :as {params :body}]
    (try
      (let [kw (crafting-recipe-kw-params params)]
        (validate-crafting-recipe-rules! kw)
        (let [int-id (Integer/parseInt id)]
          (update-crafting-recipe! int-id params)
          (if-let [record (queries/get-crafting-recipe-by-id db-spec {:id int-id})]
            (resp/response record)
            (-> (resp/response {:error "Not found"}) (resp/status 404)))))
      (catch clojure.lang.ExceptionInfo e
        (-> (resp/response {:errors (:errors (ex-data e))}) (resp/status 422)))
      (catch Exception e
        (-> (resp/response {:error (.getMessage e)}) (resp/status 500)))))

  (DELETE "/api/crafting_recipes/:id" [id]
    (queries/delete-crafting-recipe! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204)))
)
