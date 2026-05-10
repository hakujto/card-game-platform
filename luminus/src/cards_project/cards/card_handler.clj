(ns cards_project.cards.card-handler
  (:require [compojure.core :refer [defroutes GET POST PUT PATCH DELETE]]
            [ring.util.response :as resp]
            [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.cards.card-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn- insert-card! [params]
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :card_type :rarity :mana_cost :mana_colors :attack :defense :loyalty :description :flavor_text :image_url :artist_name :legal_formats :is_banned :is_restricted :power_level :set_id :rulings_id :abilities_id}
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
  (let [kw-params (into {} (map (fn [[k v]] [(keyword (name k)) v]) params))
        allowed  #{:name :card_type :rarity :mana_cost :mana_colors :attack :defense :loyalty :description :flavor_text :image_url :artist_name :legal_formats :is_banned :is_restricted :power_level :set_id :rulings_id :abilities_id}
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
    (let [new-id (insert-card! params)
          record  (or (queries/get-card-by-id db-spec {:id new-id}) {:id new-id})]
      (-> (resp/response record) (resp/status 201))))

  (GET "/api/cards/:id" [id]
    (if-let [record (queries/get-card-by-id db-spec {:id (Integer/parseInt id)})]
      (resp/response record)
      (-> (resp/response {:error "Not found"}) (resp/status 404))))

  (PUT "/api/cards/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-card! int-id params)
      (if-let [record (queries/get-card-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (PATCH "/api/cards/:id" [id :as {params :body}]
    (let [int-id (Integer/parseInt id)]
      (update-card! int-id params)
      (if-let [record (queries/get-card-by-id db-spec {:id int-id})]
        (resp/response record)
        (-> (resp/response {:error "Not found"}) (resp/status 404)))))

  (DELETE "/api/cards/:id" [id]
    (queries/delete-card! db-spec {:id (Integer/parseInt id)})
    (-> (resp/response nil) (resp/status 204))))
