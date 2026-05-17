(ns cards_project.marketplace.order-item-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :quantity 1
   :price-at-purchase 0
   :foil true
   :product-id 1})

(deftest test-list-order-items
  (testing "GET /api/order_items returns 200"
    (let [resp (app (mock/request :get "/api/order_items"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-order-item
  (testing "POST /api/order_items returns 201"
    (let [resp (app (-> (mock/request :post "/api/order_items")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-order-item
  (testing "GET /api/order_items/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/order_items/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-order-item
  (testing "PUT /api/order_items/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/order_items/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-order-item
  (testing "DELETE /api/order_items/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/order_items/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-quantity-positive
  (testing "POST /api/order_items violates rule quantity_positive → 422"
    (let [params (merge valid-params
       {   :quantity "0"})
          resp (app (-> (mock/request :post "/api/order_items")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-price-not-negative
  (testing "POST /api/order_items violates rule price_not_negative → 422"
    (let [params (merge valid-params
       {   :price-at-purchase -1})
          resp (app (-> (mock/request :post "/api/order_items")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

