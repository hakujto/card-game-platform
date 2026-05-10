(ns cards_project.marketplace.trade-bid-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :amount 0.00M
   :placed-at "2024-01-01T00:00:00"
   :is-winning true
   :listing-id 1
   :bidder-id 1})

(deftest test-list-trade-bids
  (testing "GET /api/trade_bids returns 200"
    (let [resp (app (mock/request :get "/api/trade_bids"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-trade-bid
  (testing "POST /api/trade_bids returns 201"
    (let [resp (app (-> (mock/request :post "/api/trade_bids")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-trade-bid
  (testing "GET /api/trade_bids/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/trade_bids/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-trade-bid
  (testing "PUT /api/trade_bids/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/trade_bids/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-trade-bid
  (testing "DELETE /api/trade_bids/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/trade_bids/1"))]
      (is (#{204 404} (:status resp)))))
)

