(ns cards_project.content.article-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.article-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-article
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- publish-behavior! [id]
  (throw (ex-info "publish not implemented" {:id id})))

(defn- archive-behavior! [id]
  (throw (ex-info "archive not implemented" {:id id})))

(defn- increment-view-behavior! [id]
  (throw (ex-info "increment_view not implemented" {:id id})))

(defn- reading-time-minutes-behavior! [id]
  (throw (ex-info "reading_time_minutes not implemented" {:id id})))

(defn publish!
  [id]
  (if (queries/get-article-by-id db-spec {:id id})
    (publish-behavior! id)
    (throw (ex-info "Article not found" {:id id}))))

(defn archive!
  [id]
  (if (queries/get-article-by-id db-spec {:id id})
    (archive-behavior! id)
    (throw (ex-info "Article not found" {:id id}))))

(defn increment-view!
  [id]
  (if (queries/get-article-by-id db-spec {:id id})
    (increment-view-behavior! id)
    (throw (ex-info "Article not found" {:id id}))))

