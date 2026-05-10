(ns cards_project.marketplace.order-item-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :quantity 0
   :price-at-purchase 0.00M
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
      (is (= 201 (:status resp)))))
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
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-order-item
  (testing "DELETE /api/order_items/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/order_items/1"))]
      (is (#{204 404} (:status resp)))))
)

