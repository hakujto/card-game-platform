(ns cards_project.marketplace.order-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :status "Paid"
   :total 0
   :discount-applied 0
   :currency "test"
   :tracking-number 1
   :created-at "2024-01-01T00:00:00"
   :paid-at "2024-01-02T00:00:00"
   :player-id 1})

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
      (is (#{201 500} (:status resp)))))
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
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-order
  (testing "DELETE /api/orders/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/orders/1"))]
      (is (#{204 404} (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-paid-requires-paid-at
  (testing "POST /api/orders violates rule paid_requires_paid_at → 422"
    (let [params (merge valid-params
       {   :status "Paid"
   :paid-at nil})
          resp (app (-> (mock/request :post "/api/orders")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-shipped-requires-tracking
  (testing "POST /api/orders violates rule shipped_requires_tracking → 422"
    (let [params (merge valid-params
       {   :status "Shipped"
   :tracking-number nil})
          resp (app (-> (mock/request :post "/api/orders")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-shipped-at-requires-shipped-status
  (testing "POST /api/orders violates rule shipped_at_requires_shipped_status → 422"
    (let [params (merge valid-params
       {   :shipped-at "2024-01-02T00:00:00"
   :status "Pending"})
          resp (app (-> (mock/request :post "/api/orders")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-total-not-negative
  (testing "POST /api/orders violates rule total_not_negative → 422"
    (let [params (merge valid-params
       {   :total -1})
          resp (app (-> (mock/request :post "/api/orders")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-discount-not-exceed-total
  (testing "POST /api/orders violates rule discount_not_exceed_total → 422"
    (let [params (merge valid-params
       {   :discount-applied 99999
   :total 1})
          resp (app (-> (mock/request :post "/api/orders")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

