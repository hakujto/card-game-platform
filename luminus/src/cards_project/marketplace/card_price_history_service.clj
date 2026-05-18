(ns cards_project.marketplace.card-price-history-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.card-price-history-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-card-price-history
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- price-change-percent-behavior! [id previous-avg]
  (throw (ex-info "price_change_percent not implemented" {:id id})))

(defn- is-price-spike-behavior! [id threshold-percent]
  (throw (ex-info "is_price_spike not implemented" {:id id})))

(defn price-change-percent!
  [id previous-avg]
  (if (queries/get-card-price-history-by-id db-spec {:id id})
    (price-change-percent-behavior! id previous-avg)
    (throw (ex-info "CardPriceHistory not found" {:id id}))))

(defn is-price-spike!
  [id threshold-percent]
  (if (queries/get-card-price-history-by-id db-spec {:id id})
    (is-price-spike-behavior! id threshold-percent)
    (throw (ex-info "CardPriceHistory not found" {:id id}))))

