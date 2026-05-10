(ns cards_project.marketplace.coupon-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :code "test"
   :discount-type "Percent"
   :discount-value 0.00M
   :min-order-value 0.00M
   :uses-count 0
   :valid-from "2024-01-01T00:00:00"
   :valid-until "2024-01-01T00:00:00"
   :is-active true})

(deftest test-list-coupons
  (testing "GET /api/coupons returns 200"
    (let [resp (app (mock/request :get "/api/coupons"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-coupon
  (testing "POST /api/coupons returns 201"
    (let [resp (app (-> (mock/request :post "/api/coupons")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-coupon
  (testing "GET /api/coupons/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/coupons/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-coupon
  (testing "PUT /api/coupons/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/coupons/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-coupon
  (testing "DELETE /api/coupons/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/coupons/1"))]
      (is (#{204 404} (:status resp)))))
)

