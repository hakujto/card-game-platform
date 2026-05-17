(ns cards_project.cards.card-set-service
)

(defn validate-card-set
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- is-legal-in-standard-behavior! [id]
  (throw (ex-info "is_legal_in_standard not implemented" {:id id})))

