(ns cards_project.players.player-achievement-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.players.player-achievement-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-player-achievement
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- increment-progress-behavior! [id amount]
  (throw (ex-info "increment_progress not implemented" {:id id})))

(defn- complete-behavior! [id]
  (throw (ex-info "complete not implemented" {:id id})))

(defn increment-progress!
  [id amount]
  (if (queries/get-player-achievement-by-id db-spec {:id id})
    (increment-progress-behavior! id amount)
    (throw (ex-info "PlayerAchievement not found" {:id id}))))

(defn complete!
  [id]
  (if (queries/get-player-achievement-by-id db-spec {:id id})
    (complete-behavior! id)
    (throw (ex-info "PlayerAchievement not found" {:id id}))))

; triggered by @on(is_completed = true)
(defn set-is-completed!
  [id value]
  (if-let [record (queries/get-player-achievement-by-id db-spec {:id id})]
    (do
      (jdbc/execute-one! db-spec
        ["UPDATE player_achievements SET is_completed = ? WHERE id = ?" value id])
      (when (= (clojure.string/upper-case (str value)) "TRUE")
        (complete-behavior! id)))
    (throw (ex-info "PlayerAchievement not found" {:id id}))))

