(ns cards_project.content.article-tag-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.article-tag-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-article-tag
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- rename-behavior! [id new-name]
  (throw (ex-info "rename not implemented" {:id id})))

(defn- article-count-behavior! [id]
  (throw (ex-info "article_count not implemented" {:id id})))

(defn rename!
  [id new-name]
  (if (queries/get-article-tag-by-id db-spec {:id id})
    (rename-behavior! id new-name)
    (throw (ex-info "ArticleTag not found" {:id id}))))

(defn article-count!
  [id]
  (if (queries/get-article-tag-by-id db-spec {:id id})
    (article-count-behavior! id)
    (throw (ex-info "ArticleTag not found" {:id id}))))

