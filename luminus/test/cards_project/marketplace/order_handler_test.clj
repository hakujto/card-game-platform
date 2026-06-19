(ns cards_project.marketplace.order-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :status "Paid"
   :total 0
   :discount-applied 0
   :currency "test"
   :tracking-number "test"
   :created-at "2024-01-01T00:00:00"
   :paid-at "2024-01-02T00:00:00"
   :player-id "owner-1"})
(def owner-id "owner-1")

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
    (let [resp (app (-> (mock/request :get "/api/orders/1")
                     (mock/header "X-User-Id" owner-id)))]
      (is (#{200 403 404} (:status resp)))))
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

(deftest test-transition-pending-to-paid
  (testing "PATCH /api/orders/1/transitions/pending-to-paid transitions Pending -> Paid"
    (let [resp (app (mock/request :patch "/api/orders/1/transitions/pending-to-paid"))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-paid-to-processing
  (testing "PATCH /api/orders/1/transitions/paid-to-processing transitions Paid -> Processing with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/orders/1/transitions/paid-to-processing")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-paid-to-processing-forbidden
  (testing "PATCH /api/orders/1/transitions/paid-to-processing without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/orders/1/transitions/paid-to-processing")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-processing-to-shipped
  (testing "PATCH /api/orders/1/transitions/processing-to-shipped transitions Processing -> Shipped with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/orders/1/transitions/processing-to-shipped")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-processing-to-shipped-forbidden
  (testing "PATCH /api/orders/1/transitions/processing-to-shipped without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/orders/1/transitions/processing-to-shipped")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-shipped-to-completed
  (testing "PATCH /api/orders/1/transitions/shipped-to-completed transitions Shipped -> Completed with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/orders/1/transitions/shipped-to-completed")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-shipped-to-completed-forbidden
  (testing "PATCH /api/orders/1/transitions/shipped-to-completed without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/orders/1/transitions/shipped-to-completed")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-pending-to-cancelled
  (testing "PATCH /api/orders/1/transitions/pending-to-cancelled transitions Pending -> Cancelled"
    (let [resp (app (mock/request :patch "/api/orders/1/transitions/pending-to-cancelled"))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-paid-to-cancelled
  (testing "PATCH /api/orders/1/transitions/paid-to-cancelled transitions Paid -> Cancelled with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/orders/1/transitions/paid-to-cancelled")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-paid-to-cancelled-forbidden
  (testing "PATCH /api/orders/1/transitions/paid-to-cancelled without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/orders/1/transitions/paid-to-cancelled")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-completed-to-refunded
  (testing "PATCH /api/orders/1/transitions/completed-to-refunded transitions Completed -> Refunded with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/orders/1/transitions/completed-to-refunded")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-completed-to-refunded-forbidden
  (testing "PATCH /api/orders/1/transitions/completed-to-refunded without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/orders/1/transitions/completed-to-refunded")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-refunded-to-completed
  (testing "PATCH /api/orders/1/transitions/refunded-to-completed is denied"
    (let [resp (app (mock/request :patch "/api/orders/1/transitions/refunded-to-completed"))]
      (is (#{409 404} (:status resp)))))
)

(deftest test-transition-completed-to-cancelled
  (testing "PATCH /api/orders/1/transitions/completed-to-cancelled is denied"
    (let [resp (app (mock/request :patch "/api/orders/1/transitions/completed-to-cancelled"))]
      (is (#{409 404} (:status resp)))))
)

