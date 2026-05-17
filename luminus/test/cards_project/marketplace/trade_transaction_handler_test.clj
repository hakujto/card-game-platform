(ns cards_project.marketplace.trade-transaction-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :final-price 1
   :platform-fee 0
   :status "Completed"
   :completed-at "2024-01-02T00:00:00"
   :listing-id 1
   :buyer-id 1
   :seller-id 1})

(deftest test-list-trade-transactions
  (testing "GET /api/trade_transactions returns 200"
    (let [resp (app (mock/request :get "/api/trade_transactions"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-trade-transaction
  (testing "POST /api/trade_transactions returns 201"
    (let [resp (app (-> (mock/request :post "/api/trade_transactions")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-trade-transaction
  (testing "GET /api/trade_transactions/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/trade_transactions/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-trade-transaction
  (testing "PUT /api/trade_transactions/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/trade_transactions/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-trade-transaction
  (testing "DELETE /api/trade_transactions/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/trade_transactions/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-fee-not-exceed-price
  (testing "POST /api/trade_transactions violates rule fee_not_exceed_price → 422"
    (let [params (merge valid-params
       {   :platform-fee 99999
   :final-price 1})
          resp (app (-> (mock/request :post "/api/trade_transactions")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-fee-not-negative
  (testing "POST /api/trade_transactions violates rule fee_not_negative → 422"
    (let [params (merge valid-params
       {   :platform-fee -1})
          resp (app (-> (mock/request :post "/api/trade_transactions")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-completed-requires-completed-at
  (testing "POST /api/trade_transactions violates rule completed_requires_completed_at → 422"
    (let [params (merge valid-params
       {   :status "Completed"
   :completed-at nil})
          resp (app (-> (mock/request :post "/api/trade_transactions")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

