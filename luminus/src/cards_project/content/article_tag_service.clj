(ns cards_project.content.article-tag-service
)

(defn validate-article-tag
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- rename-behavior! [id new-name]
  (throw (ex-info "rename not implemented" {:id id})))

(defn- article-count-behavior! [id]
  (throw (ex-info "article_count not implemented" {:id id})))

