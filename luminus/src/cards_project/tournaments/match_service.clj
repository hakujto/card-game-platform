(ns cards_project.tournaments.match-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.match-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-match
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- record-result-behavior! [id p1-wins p2-wins]
  ; TODO: implement record_result
  nil)

(defn- finalize-result-behavior! [id]
  ; TODO: implement finalize_result
  nil)

(defn- determine-winner-behavior! [id]
  ; TODO: implement determine_winner
  nil)

(defn- concede-behavior! [id player-id]
  ; TODO: implement concede
  nil)

(defn- draw-behavior! [id]
  ; TODO: implement draw
  nil)

; ── Lifecycle state machine ─────────────────────────────────────────
(def ^:private allowed-transitions
  {   "Pending" ["Active", "BYE"]
   "Active" ["Completed", "Draw"]})

(defn- assert-transition! [current to]
  (let [allowed (get allowed-transitions current [])]
    (when-not (some #(= % to) allowed)
      (throw (ex-info (str "Transition " current " -> " to " not allowed")
                      {:status 409})))))

(defn transition-pending-to-active!
  [id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Active")
      (jdbc/execute-one! db-spec
        ["UPDATE matches SET status = ? WHERE id = ?" "Active" id])
      (queries/get-match-by-id db-spec {:id id}))
    (throw (ex-info "Match not found" {:id id :status 404}))))

(defn transition-active-to-completed!
  [id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Completed")
      (jdbc/execute-one! db-spec
        ["UPDATE matches SET status = ? WHERE id = ?" "Completed" id])
      (finalize-result-behavior! id) ; @after
      (queries/get-match-by-id db-spec {:id id}))
    (throw (ex-info "Match not found" {:id id :status 404}))))

(defn transition-active-to-draw!
  [id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Draw")
      (jdbc/execute-one! db-spec
        ["UPDATE matches SET status = ? WHERE id = ?" "Draw" id])
      (draw-behavior! id) ; @after
      (queries/get-match-by-id db-spec {:id id}))
    (throw (ex-info "Match not found" {:id id :status 404}))))

(defn transition-pending-to-b-y-e!
  [id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "BYE")
      (jdbc/execute-one! db-spec
        ["UPDATE matches SET status = ? WHERE id = ?" "BYE" id])
      (queries/get-match-by-id db-spec {:id id}))
    (throw (ex-info "Match not found" {:id id :status 404}))))

(defn transition-completed-to-active!
  [id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (throw (ex-info "Transition Completed -> Active is not allowed" {:status 409}))
    (throw (ex-info "Match not found" {:id id :status 404}))))

(defn transition-draw-to-active!
  [id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (throw (ex-info "Transition Draw -> Active is not allowed" {:status 409}))
    (throw (ex-info "Match not found" {:id id :status 404}))))

(defn transition-b-y-e-to-active!
  [id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (throw (ex-info "Transition BYE -> Active is not allowed" {:status 409}))
    (throw (ex-info "Match not found" {:id id :status 404}))))

(defn record-result!
  [id p1-wins p2-wins]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (do
      (record-result-behavior! id p1-wins p2-wins)
      (determine-winner-behavior! id))
    (throw (ex-info "Match not found" {:id id}))))

(defn finalize-result!
  [id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (do
      (finalize-result-behavior! id)
      (determine-winner-behavior! id))
    (throw (ex-info "Match not found" {:id id}))))

(defn determine-winner!
  [id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (determine-winner-behavior! id)
    (throw (ex-info "Match not found" {:id id}))))

(defn concede!
  [id player-id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (concede-behavior! id player-id)
    (throw (ex-info "Match not found" {:id id}))))

(defn draw!
  [id]
  (if-let [record (queries/get-match-by-id db-spec {:id id})]
    (draw-behavior! id)
    (throw (ex-info "Match not found" {:id id}))))

