(ns cards_project.content.stream-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.stream-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-stream
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- go-live-behavior! [id]
  (throw (ex-info "go_live not implemented" {:id id})))

(defn- end-behavior! [id]
  (throw (ex-info "end not implemented" {:id id})))

(defn- update-viewer-peak-behavior! [id count]
  (throw (ex-info "update_viewer_peak not implemented" {:id id})))

(defn- duration-minutes-behavior! [id]
  (throw (ex-info "duration_minutes not implemented" {:id id})))

(defn go-live!
  [id]
  (if (queries/get-stream-by-id db-spec {:id id})
    (go-live-behavior! id)
    (throw (ex-info "Stream not found" {:id id}))))

(defn end!
  [id]
  (if (queries/get-stream-by-id db-spec {:id id})
    (end-behavior! id)
    (throw (ex-info "Stream not found" {:id id}))))

(defn update-viewer-peak!
  [id count]
  (if (queries/get-stream-by-id db-spec {:id id})
    (update-viewer-peak-behavior! id count)
    (throw (ex-info "Stream not found" {:id id}))))

(defn duration-minutes!
  [id]
  (if (queries/get-stream-by-id db-spec {:id id})
    (duration-minutes-behavior! id)
    (throw (ex-info "Stream not found" {:id id}))))

