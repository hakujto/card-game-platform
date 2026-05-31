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
  ; TODO: implement go_live
  nil)

(defn- end-behavior! [id]
  ; TODO: implement end
  nil)

(defn- update-viewer-peak-behavior! [id count]
  ; TODO: implement update_viewer_peak
  nil)

(defn- duration-minutes-behavior! [id]
  ; TODO: implement duration_minutes
  nil)

; ── Lifecycle state machine ─────────────────────────────────────────
(def ^:private allowed-transitions
  {   "Scheduled" ["Live"]
   "Live" ["Ended"]})

(defn- assert-transition! [current to]
  (let [allowed (get allowed-transitions current [])]
    (when-not (some #(= % to) allowed)
      (throw (ex-info (str "Transition " current " -> " to " not allowed")
                      {:status 409})))))

(defn transition-scheduled-to-live!
  [id]
  (if-let [record (queries/get-stream-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Live")
      (when (nil? (get record :stream_url))
        (throw (ex-info "stream_url is required for Scheduled -> Live" {:status 422})))
      (jdbc/execute-one! db-spec
        ["UPDATE streams SET status = ? WHERE id = ?" "Live" id])
      (go-live-behavior! id) ; @after
      (queries/get-stream-by-id db-spec {:id id}))
    (throw (ex-info "Stream not found" {:id id :status 404}))))

(defn transition-live-to-ended!
  [id]
  (if-let [record (queries/get-stream-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Ended")
      (jdbc/execute-one! db-spec
        ["UPDATE streams SET status = ? WHERE id = ?" "Ended" id])
      (end-behavior! id) ; @after
      (queries/get-stream-by-id db-spec {:id id}))
    (throw (ex-info "Stream not found" {:id id :status 404}))))

(defn transition-ended-to-live!
  [id]
  (if-let [record (queries/get-stream-by-id db-spec {:id id})]
    (throw (ex-info "Transition Ended -> Live is not allowed" {:status 409}))
    (throw (ex-info "Stream not found" {:id id :status 404}))))

(defn go-live!
  [id]
  (if-let [record (queries/get-stream-by-id db-spec {:id id})]
    (go-live-behavior! id)
    (throw (ex-info "Stream not found" {:id id}))))

(defn end!
  [id]
  (if-let [record (queries/get-stream-by-id db-spec {:id id})]
    (end-behavior! id)
    (throw (ex-info "Stream not found" {:id id}))))

(defn update-viewer-peak!
  [id count]
  (if-let [record (queries/get-stream-by-id db-spec {:id id})]
    (update-viewer-peak-behavior! id count)
    (throw (ex-info "Stream not found" {:id id}))))

(defn duration-minutes!
  [id]
  (if-let [record (queries/get-stream-by-id db-spec {:id id})]
    (duration-minutes-behavior! id)
    (throw (ex-info "Stream not found" {:id id}))))

