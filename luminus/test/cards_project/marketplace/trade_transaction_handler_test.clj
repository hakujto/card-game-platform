(ns cards_project.marketplace.trade-transaction-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :final-price 0.00M
   :platform-fee 0.00M
   :status "Pending"
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
      (is (= 201 (:status resp)))))
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
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-trade-transaction
  (testing "DELETE /api/trade_transactions/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/trade_transactions/1"))]
      (is (#{204 404} (:status resp)))))
)

