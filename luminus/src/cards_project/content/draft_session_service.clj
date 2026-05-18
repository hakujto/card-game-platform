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
  (throw (ex-info "start not implemented" {:id id})))

(defn- abandon-behavior! [id]
  (throw (ex-info "abandon not implemented" {:id id})))

(defn- complete-behavior! [id]
  (throw (ex-info "complete not implemented" {:id id})))

(defn- is-full-behavior! [id]
  (throw (ex-info "is_full not implemented" {:id id})))

(defn start!
  [id]
  (if (queries/get-draft-session-by-id db-spec {:id id})
    (start-behavior! id)
    (throw (ex-info "DraftSession not found" {:id id}))))

(defn abandon!
  [id]
  (if (queries/get-draft-session-by-id db-spec {:id id})
    (abandon-behavior! id)
    (throw (ex-info "DraftSession not found" {:id id}))))

(defn complete!
  [id]
  (if (queries/get-draft-session-by-id db-spec {:id id})
    (complete-behavior! id)
    (throw (ex-info "DraftSession not found" {:id id}))))

(defn is-full!
  [id]
  (if (queries/get-draft-session-by-id db-spec {:id id})
    (is-full-behavior! id)
    (throw (ex-info "DraftSession not found" {:id id}))))

