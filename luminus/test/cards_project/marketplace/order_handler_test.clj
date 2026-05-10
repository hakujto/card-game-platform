(ns cards_project.marketplace.order-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :status "Pending"
   :total 0.00M
   :discount-applied 0.00M
   :currency "test"
   :created-at "2024-01-01T00:00:00"
   :player-id 1
   :items-id 1})

(deftest test-list-orders
  (testing "GET /api/orders returns 200"
    (let [resp (app (mock/request :get "/api/orders"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-order
  (testing "POST /api/orders returns 201"
    (let [resp (app (-> (mock/request :post "/api/orders")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-order
  (testing "GET /api/orders/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/orders/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-order
  (testing "PUT /api/orders/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/orders/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-order
  (testing "DELETE /api/orders/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/orders/1"))]
      (is (#{204 404} (:status resp)))))
)

