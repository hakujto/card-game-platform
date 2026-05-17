(ns cards_project.marketplace.product-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.marketplace.product-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-product
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- activate-behavior! [id]
  (throw (ex-info "activate not implemented" {:id id})))

(defn- deactivate-behavior! [id]
  (throw (ex-info "deactivate not implemented" {:id id})))

(defn- apply-discount-behavior! [id percent]
  (throw (ex-info "apply_discount not implemented" {:id id})))

(defn- restock-behavior! [id quantity]
  (throw (ex-info "restock not implemented" {:id id})))

(defn- effective-price-behavior! [id]
  (throw (ex-info "effective_price not implemented" {:id id})))

(defn- is-in-stock-behavior! [id]
  (throw (ex-info "is_in_stock not implemented" {:id id})))

(defn activate!
  [id]
  (if (queries/get-product-by-id db-spec {:id id})
    (activate-behavior! id)
    (throw (ex-info "Product not found" {:id id}))))

(defn deactivate!
  [id]
  (if (queries/get-product-by-id db-spec {:id id})
    (deactivate-behavior! id)
    (throw (ex-info "Product not found" {:id id}))))

(defn apply-discount!
  [id percent]
  (if (queries/get-product-by-id db-spec {:id id})
    (apply-discount-behavior! id percent)
    (throw (ex-info "Product not found" {:id id}))))

(defn restock!
  [id quantity]
  (if (queries/get-product-by-id db-spec {:id id})
    (restock-behavior! id quantity)
    (throw (ex-info "Product not found" {:id id}))))

