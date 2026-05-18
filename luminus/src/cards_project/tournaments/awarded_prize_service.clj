(ns cards_project.tournaments.awarded-prize-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.tournaments.awarded-prize-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-awarded-prize
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- claim-behavior! [id]
  (throw (ex-info "claim not implemented" {:id id})))

(defn claim!
  [id]
  (if (queries/get-awarded-prize-by-id db-spec {:id id})
    (claim-behavior! id)
    (throw (ex-info "AwardedPrize not found" {:id id}))))

; triggered by @on(claimed = true)
(defn set-claimed!
  [id value]
  (if-let [record (queries/get-awarded-prize-by-id db-spec {:id id})]
    (do
      (jdbc/execute-one! db-spec
        ["UPDATE awarded_prizes SET claimed = ? WHERE id = ?" value id])
      (when (= (clojure.string/upper-case (str value)) "TRUE")
        (claim-behavior! id)))
    (throw (ex-info "AwardedPrize not found" {:id id}))))

