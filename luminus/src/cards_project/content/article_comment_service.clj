(ns cards_project.content.article-comment-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.article-comment-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-article-comment
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- hide-behavior! [id]
  (throw (ex-info "hide not implemented" {:id id})))

(defn- unhide-behavior! [id]
  (throw (ex-info "unhide not implemented" {:id id})))

(defn- is-reply-behavior! [id]
  (throw (ex-info "is_reply not implemented" {:id id})))

(defn hide!
  [id]
  (if (queries/get-article-comment-by-id db-spec {:id id})
    (hide-behavior! id)
    (throw (ex-info "ArticleComment not found" {:id id}))))

(defn unhide!
  [id]
  (if (queries/get-article-comment-by-id db-spec {:id id})
    (unhide-behavior! id)
    (throw (ex-info "ArticleComment not found" {:id id}))))

(defn is-reply!
  [id]
  (if (queries/get-article-comment-by-id db-spec {:id id})
    (is-reply-behavior! id)
    (throw (ex-info "ArticleComment not found" {:id id}))))

