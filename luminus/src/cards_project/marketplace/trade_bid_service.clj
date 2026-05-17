(ns cards_project.marketplace.trade-bid-service
)

(defn validate-trade-bid
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- outbid-by-behavior! [id new-amount]
  (throw (ex-info "outbid_by not implemented" {:id id})))

