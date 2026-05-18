(ns cards_project.tournaments.tournament-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.tournament-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-tournament
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- start-behavior! [id]
  (throw (ex-info "start not implemented" {:id id})))

(defn- cancel-behavior! [id]
  (throw (ex-info "cancel not implemented" {:id id})))

(defn- complete-behavior! [id]
  (throw (ex-info "complete not implemented" {:id id})))

(defn- generate-round-behavior! [id]
  (throw (ex-info "generate_round not implemented" {:id id})))

(defn- calculate-prize-distribution-behavior! [id]
  (throw (ex-info "calculate_prize_distribution not implemented" {:id id})))

(defn- register-player-behavior! [id player-id deck-id]
  (throw (ex-info "register_player not implemented" {:id id})))

(defn- is-full-behavior! [id]
  (throw (ex-info "is_full not implemented" {:id id})))

(defn start!
  [id]
  (if (queries/get-tournament-by-id db-spec {:id id})
    (start-behavior! id)
    (throw (ex-info "Tournament not found" {:id id}))))

(defn cancel!
  [id]
  (if (queries/get-tournament-by-id db-spec {:id id})
    (cancel-behavior! id)
    (throw (ex-info "Tournament not found" {:id id}))))

(defn complete!
  [id]
  (if (queries/get-tournament-by-id db-spec {:id id})
    (complete-behavior! id)
    (throw (ex-info "Tournament not found" {:id id}))))

(defn generate-round!
  [id]
  (if (queries/get-tournament-by-id db-spec {:id id})
    (generate-round-behavior! id)
    (throw (ex-info "Tournament not found" {:id id}))))

(defn calculate-prize-distribution!
  [id]
  (if (queries/get-tournament-by-id db-spec {:id id})
    (calculate-prize-distribution-behavior! id)
    (throw (ex-info "Tournament not found" {:id id}))))

(defn register-player!
  [id player-id deck-id]
  (if (queries/get-tournament-by-id db-spec {:id id})
    (register-player-behavior! id player-id deck-id)
    (throw (ex-info "Tournament not found" {:id id}))))

(defn is-full!
  [id]
  (if (queries/get-tournament-by-id db-spec {:id id})
    (is-full-behavior! id)
    (throw (ex-info "Tournament not found" {:id id}))))

