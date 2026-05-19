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
  ; TODO: implement start
  nil)

(defn- cancel-behavior! [id]
  ; TODO: implement cancel
  nil)

(defn- complete-behavior! [id]
  ; TODO: implement complete
  nil)

(defn- generate-round-behavior! [id]
  ; TODO: implement generate_round
  nil)

(defn- calculate-prize-distribution-behavior! [id]
  ; TODO: implement calculate_prize_distribution
  nil)

(defn- register-player-behavior! [id player-id deck-id]
  ; TODO: implement register_player
  nil)

(defn- is-full-behavior! [id]
  ; TODO: implement is_full
  nil)

; ── Lifecycle state machine ─────────────────────────────────────────
(def ^:private allowed-transitions
  {   "Draft" ["Registration"]
   "Registration" ["Ongoing", "Cancelled"]
   "Ongoing" ["Completed", "Cancelled"]})

(defn- assert-transition! [current to]
  (let [allowed (get allowed-transitions current [])]
    (when-not (some #(= % to) allowed)
      (throw (ex-info (str "Transition " current " -> " to " not allowed")
                      {:status 409})))))

(defn transition-draft-to-registration!
  [id]
  (if-let [record (queries/get-tournament-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Registration")
      (when (nil? (get record :name))
        (throw (ex-info "name is required for Draft -> Registration" {:status 422})))
      (when (nil? (get record :start_time))
        (throw (ex-info "start_time is required for Draft -> Registration" {:status 422})))
      (jdbc/execute-one! db-spec
        ["UPDATE tournaments SET status = ? WHERE id = ?" "Registration" id])
      (queries/get-tournament-by-id db-spec {:id id}))
    (throw (ex-info "Tournament not found" {:id id :status 404}))))

(defn transition-registration-to-ongoing!
  [id]
  (if-let [record (queries/get-tournament-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Ongoing")
      (jdbc/execute-one! db-spec
        ["UPDATE tournaments SET status = ? WHERE id = ?" "Ongoing" id])
      (start-behavior! id) ; @after
      (queries/get-tournament-by-id db-spec {:id id}))
    (throw (ex-info "Tournament not found" {:id id :status 404}))))

(defn transition-registration-to-cancelled!
  [id]
  (if-let [record (queries/get-tournament-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Cancelled")
      (jdbc/execute-one! db-spec
        ["UPDATE tournaments SET status = ? WHERE id = ?" "Cancelled" id])
      (cancel-behavior! id) ; @after
      (queries/get-tournament-by-id db-spec {:id id}))
    (throw (ex-info "Tournament not found" {:id id :status 404}))))

(defn transition-ongoing-to-completed!
  [id]
  (if-let [record (queries/get-tournament-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Completed")
      (jdbc/execute-one! db-spec
        ["UPDATE tournaments SET status = ? WHERE id = ?" "Completed" id])
      (complete-behavior! id) ; @after
      (calculate-prize-distribution-behavior! id) ; @after
      (queries/get-tournament-by-id db-spec {:id id}))
    (throw (ex-info "Tournament not found" {:id id :status 404}))))

(defn transition-ongoing-to-cancelled!
  [id]
  (if-let [record (queries/get-tournament-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Cancelled")
      (jdbc/execute-one! db-spec
        ["UPDATE tournaments SET status = ? WHERE id = ?" "Cancelled" id])
      (cancel-behavior! id) ; @after
      (queries/get-tournament-by-id db-spec {:id id}))
    (throw (ex-info "Tournament not found" {:id id :status 404}))))

(defn transition-completed-to-draft!
  [id]
  (if-let [record (queries/get-tournament-by-id db-spec {:id id})]
    (throw (ex-info "Transition Completed -> Draft is not allowed" {:status 409}))
    (throw (ex-info "Tournament not found" {:id id :status 404}))))

(defn transition-cancelled-to-draft!
  [id]
  (if-let [record (queries/get-tournament-by-id db-spec {:id id})]
    (throw (ex-info "Transition Cancelled -> Draft is not allowed" {:status 409}))
    (throw (ex-info "Tournament not found" {:id id :status 404}))))

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

