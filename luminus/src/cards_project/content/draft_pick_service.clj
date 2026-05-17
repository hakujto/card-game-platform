(ns cards_project.content.draft-pick-service
)

(defn validate-draft-pick
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- is-first-pick-behavior! [id]
  (throw (ex-info "is_first_pick not implemented" {:id id})))

