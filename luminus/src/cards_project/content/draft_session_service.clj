(ns cards_project.content.draft-session-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.draft-session-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-draft-session
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- start-behavior! [id]
  ; TODO: implement start
  nil)

(defn- abandon-behavior! [id]
  ; TODO: implement abandon
  nil)

(defn- complete-behavior! [id]
  ; TODO: implement complete
  nil)

(defn- is-full-behavior! [id]
  ; TODO: implement is_full
  nil)

; ── Lifecycle state machine ─────────────────────────────────────────
(def ^:private allowed-transitions
  {   "WaitingForPlayers" ["Drafting", "Abandoned"]
   "Drafting" ["Completed", "Abandoned"]})

(defn- assert-transition! [current to]
  (let [allowed (get allowed-transitions current [])]
    (when-not (some #(= % to) allowed)
      (throw (ex-info (str "Transition " current " -> " to " not allowed")
                      {:status 409})))))

(defn transition-waiting-for-players-to-drafting!
  [id]
  (if-let [record (queries/get-draft-session-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Drafting")
      (jdbc/execute-one! db-spec
        ["UPDATE draft_sessions SET status = ? WHERE id = ?" "Drafting" id])
      (start-behavior! id) ; @after
      (queries/get-draft-session-by-id db-spec {:id id}))
    (throw (ex-info "DraftSession not found" {:id id :status 404}))))

(defn transition-drafting-to-completed!
  [id]
  (if-let [record (queries/get-draft-session-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Completed")
      (jdbc/execute-one! db-spec
        ["UPDATE draft_sessions SET status = ? WHERE id = ?" "Completed" id])
      (complete-behavior! id) ; @after
      (queries/get-draft-session-by-id db-spec {:id id}))
    (throw (ex-info "DraftSession not found" {:id id :status 404}))))

(defn transition-drafting-to-abandoned!
  [id]
  (if-let [record (queries/get-draft-session-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Abandoned")
      (jdbc/execute-one! db-spec
        ["UPDATE draft_sessions SET status = ? WHERE id = ?" "Abandoned" id])
      (abandon-behavior! id) ; @after
      (queries/get-draft-session-by-id db-spec {:id id}))
    (throw (ex-info "DraftSession not found" {:id id :status 404}))))

(defn transition-waiting-for-players-to-abandoned!
  [id]
  (if-let [record (queries/get-draft-session-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Abandoned")
      (jdbc/execute-one! db-spec
        ["UPDATE draft_sessions SET status = ? WHERE id = ?" "Abandoned" id])
      (abandon-behavior! id) ; @after
      (queries/get-draft-session-by-id db-spec {:id id}))
    (throw (ex-info "DraftSession not found" {:id id :status 404}))))

(defn transition-completed-to-drafting!
  [id]
  (if-let [record (queries/get-draft-session-by-id db-spec {:id id})]
    (throw (ex-info "Transition Completed -> Drafting is not allowed" {:status 409}))
    (throw (ex-info "DraftSession not found" {:id id :status 404}))))

(defn transition-abandoned-to-drafting!
  [id]
  (if-let [record (queries/get-draft-session-by-id db-spec {:id id})]
    (throw (ex-info "Transition Abandoned -> Drafting is not allowed" {:status 409}))
    (throw (ex-info "DraftSession not found" {:id id :status 404}))))

(defn start!
  [id]
  (if-let [record (queries/get-draft-session-by-id db-spec {:id id})]
    (start-behavior! id)
    (throw (ex-info "DraftSession not found" {:id id}))))

(defn abandon!
  [id]
  (if-let [record (queries/get-draft-session-by-id db-spec {:id id})]
    (abandon-behavior! id)
    (throw (ex-info "DraftSession not found" {:id id}))))

(defn complete!
  [id]
  (if-let [record (queries/get-draft-session-by-id db-spec {:id id})]
    (complete-behavior! id)
    (throw (ex-info "DraftSession not found" {:id id}))))

(defn is-full!
  [id]
  (if-let [record (queries/get-draft-session-by-id db-spec {:id id})]
    (is-full-behavior! id)
    (throw (ex-info "DraftSession not found" {:id id}))))

