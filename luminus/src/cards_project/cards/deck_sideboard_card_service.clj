(ns cards_project.cards.deck-sideboard-card-service
)

(defn validate-deck-sideboard-card
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- increment-behavior! [id amount]
  (throw (ex-info "increment not implemented" {:id id})))

(defn- decrement-behavior! [id amount]
  (throw (ex-info "decrement not implemented" {:id id})))

