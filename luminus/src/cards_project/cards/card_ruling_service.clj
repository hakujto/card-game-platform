(ns cards_project.cards.card-ruling-service
)

(defn validate-card-ruling
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- is-current-behavior! [id]
  (throw (ex-info "is_current not implemented" {:id id})))

(defn- supersedes-previous-behavior! [id]
  (throw (ex-info "supersedes_previous not implemented" {:id id})))

