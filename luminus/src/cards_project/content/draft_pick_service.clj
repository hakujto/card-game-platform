(ns cards_project.content.draft-pick-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.draft-pick-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-draft-pick
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- is-first-pick-behavior! [id]
  (throw (ex-info "is_first_pick not implemented" {:id id})))

(defn is-first-pick!
  [id]
  (if (queries/get-draft-pick-by-id db-spec {:id id})
    (is-first-pick-behavior! id)
    (throw (ex-info "DraftPick not found" {:id id}))))

