(ns cards_project.marketplace.order-item-service
)

(defn validate-order-item
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- line-total-behavior! [id]
  (throw (ex-info "line_total not implemented" {:id id})))

