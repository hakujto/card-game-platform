(ns cards_project.marketplace.card-price-history-service
)

(defn validate-card-price-history
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- price-change-percent-behavior! [id previous-avg]
  (throw (ex-info "price_change_percent not implemented" {:id id})))

(defn- is-price-spike-behavior! [id threshold-percent]
  (throw (ex-info "is_price_spike not implemented" {:id id})))

