(ns cards_project.marketplace.coupon-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :code "test"
   :discount-type "Percent"
   :discount-value 1
   :min-order-value "0.00"
   :uses-count 0
   :valid-from "2024-01-01T00:00:00"
   :valid-until "2024-01-02T00:00:00"
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

; Simple rule violated → 422
(deftest test-rule-valid-until-after-valid-from
  (testing "POST /api/coupons violates rule valid_until_after_valid_from → 422"
    (let [params (merge valid-params
       {   :valid-until "2023-12-31T00:00:00"})
          resp (app (-> (mock/request :post "/api/coupons")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-discount-value-positive
  (testing "POST /api/coupons violates rule discount_value_positive → 422"
    (let [params (merge valid-params
       {   :discount-value "0"})
          resp (app (-> (mock/request :post "/api/coupons")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-percent-discount-range
  (testing "POST /api/coupons violates rule percent_discount_range → 422"
    (let [params (merge valid-params
       {   :discount-type "Percent"
   :discount-value 101})
          resp (app (-> (mock/request :post "/api/coupons")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-uses-not-exceed-max
  (testing "POST /api/coupons violates rule uses_not_exceed_max → 422"
    (let [params (merge valid-params
       {   :max-uses 1
   :uses-count 99999})
          resp (app (-> (mock/request :post "/api/coupons")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

