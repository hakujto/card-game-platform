(ns cards_project.content.draft-participant-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.draft-participant-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-draft-participant
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- pick-card-behavior! [id card-id pack-number]
  ; TODO: implement pick_card
  nil)

(defn- drafted-card-count-behavior! [id]
  ; TODO: implement drafted_card_count
  nil)

(defn pick-card!
  [id card-id pack-number]
  (if-let [record (queries/get-draft-participant-by-id db-spec {:id id})]
    (pick-card-behavior! id card-id pack-number)
    (throw (ex-info "DraftParticipant not found" {:id id}))))

(defn drafted-card-count!
  [id]
  (if-let [record (queries/get-draft-participant-by-id db-spec {:id id})]
    (drafted-card-count-behavior! id)
    (throw (ex-info "DraftParticipant not found" {:id id}))))

