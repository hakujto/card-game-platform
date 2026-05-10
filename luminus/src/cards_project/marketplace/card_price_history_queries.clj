(ns cards_project.marketplace.card-price-history-queries
  (:require [hugsql.core :as hugsql]
            [cards_project.db]))   ; loads set-adapter! side effect

(hugsql/def-db-fns "sql/marketplace/card_price_history.sql")
