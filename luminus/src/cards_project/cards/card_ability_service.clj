(ns cards_project.cards.card-ability-service
)

(defn validate-card-ability
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- is-usable-at-behavior! [id timing]
  (throw (ex-info "is_usable_at not implemented" {:id id})))

(defn- describe-behavior! [id]
  (throw (ex-info "describe not implemented" {:id id})))

