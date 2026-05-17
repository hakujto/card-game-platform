(ns cards_project.tournaments.tournament-prize-service
)

(defn validate-tournament-prize
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- applies-to-placement-behavior! [id placement]
  (throw (ex-info "applies_to_placement not implemented" {:id id})))

