(ns cards_project.players.player-season-stats-service
)

(defn validate-player-season-stats
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- win-rate-behavior! [id]
  (throw (ex-info "win_rate not implemented" {:id id})))

(defn- add-points-behavior! [id points]
  (throw (ex-info "add_points not implemented" {:id id})))

(defn- record-tournament-win-behavior! [id]
  (throw (ex-info "record_tournament_win not implemented" {:id id})))

