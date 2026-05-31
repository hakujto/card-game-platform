(ns cards_project.marketplace.trade-transaction-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :final-price 1
   :platform-fee 1
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

(deftest test-get-trade-transaction
  (testing "GET /api/trade_transactions/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/trade_transactions/1"))]
      (is (#{200 404} (:status resp)))))
)

