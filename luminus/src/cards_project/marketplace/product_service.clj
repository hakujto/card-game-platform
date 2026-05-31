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
  ; TODO: implement activate
  nil)

(defn- deactivate-behavior! [id]
  ; TODO: implement deactivate
  nil)

(defn- apply-discount-behavior! [id percent]
  ; TODO: implement apply_discount
  nil)

(defn- restock-behavior! [id quantity]
  ; TODO: implement restock
  nil)

(defn- effective-price-behavior! [id]
  ; TODO: implement effective_price
  nil)

(defn- is-in-stock-behavior! [id]
  ; TODO: implement is_in_stock
  nil)

(defn activate!
  [id]
  (if-let [record (queries/get-product-by-id db-spec {:id id})]
    (activate-behavior! id)
    (throw (ex-info "Product not found" {:id id}))))

(defn deactivate!
  [id]
  (if-let [record (queries/get-product-by-id db-spec {:id id})]
    (deactivate-behavior! id)
    (throw (ex-info "Product not found" {:id id}))))

(defn apply-discount!
  [id percent]
  (if-let [record (queries/get-product-by-id db-spec {:id id})]
    (apply-discount-behavior! id percent)
    (throw (ex-info "Product not found" {:id id}))))

(defn restock!
  [id quantity]
  (if-let [record (queries/get-product-by-id db-spec {:id id})]
    (restock-behavior! id quantity)
    (throw (ex-info "Product not found" {:id id}))))

(defn effective-price!
  [id]
  (if-let [record (queries/get-product-by-id db-spec {:id id})]
    (effective-price-behavior! id)
    (throw (ex-info "Product not found" {:id id}))))

(defn is-in-stock!
  [id]
  (if-let [record (queries/get-product-by-id db-spec {:id id})]
    (is-in-stock-behavior! id)
    (throw (ex-info "Product not found" {:id id}))))

