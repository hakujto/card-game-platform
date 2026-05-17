(ns cards_project.players.crafting-recipe-service
)

(defn validate-crafting-recipe
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- disable-behavior! [id]
  (throw (ex-info "disable not implemented" {:id id})))

(defn- enable-behavior! [id]
  (throw (ex-info "enable not implemented" {:id id})))

