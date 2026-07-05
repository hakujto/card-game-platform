(ns cards_project.marketplace.product-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :product-type "SingleCard"
   :price 1
   :stock 0
   :active true
   :discount-percent 0
   :featured true})

(deftest test-list-products
  (testing "GET /api/products returns 200"
    (let [resp (app (mock/request :get "/api/products"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-product
  (testing "POST /api/products returns 201"
    (let [resp (app (-> (mock/request :post "/api/products")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-product
  (testing "GET /api/products/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/products/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-product
  (testing "PUT /api/products/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/products/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-patch-product
  (testing "PATCH /api/products/1 partial update returns 200 or 404"
    (let [resp (app (-> (mock/request :patch "/api/products/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string {:description "test"}))))]
      (is (#{200 404 422} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-price-positive
  (testing "POST /api/products violates rule price_positive → 422"
    (let [params (merge valid-params
       {   :price 0})
          resp (app (-> (mock/request :post "/api/products")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-stock-not-negative
  (testing "POST /api/products violates rule stock_not_negative → 422"
    (let [params (merge valid-params
       {   :stock -1})
          resp (app (-> (mock/request :post "/api/products")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-discount-percent-range
  (testing "POST /api/products violates rule discount_percent_range → 422"
    (let [params (merge valid-params
       {   :discount-percent 101})
          resp (app (-> (mock/request :post "/api/products")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

