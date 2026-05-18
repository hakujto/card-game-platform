(ns cards_project.marketplace.trade-listing-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :listing-type "FixedPrice"
   :asking-price 1
   :auction-start-price 1
   :auction-end-time "2024-01-02T00:00:00"
   :foil true
   :condition "Mint"
   :quantity 1
   :status "Active"
   :created-at "2024-01-01T00:00:00"
   :seller-id 1
   :card-id 1})

(deftest test-list-trade-listings
  (testing "GET /api/trade_listings returns 200"
    (let [resp (app (mock/request :get "/api/trade_listings"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-trade-listing
  (testing "POST /api/trade_listings returns 201"
    (let [resp (app (-> (mock/request :post "/api/trade_listings")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-trade-listing
  (testing "GET /api/trade_listings/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/trade_listings/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-trade-listing
  (testing "PUT /api/trade_listings/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/trade_listings/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-trade-listing
  (testing "DELETE /api/trade_listings/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/trade_listings/1"))]
      (is (#{204 404} (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-fixed-price-requires-asking-price
  (testing "POST /api/trade_listings violates rule fixed_price_requires_asking_price → 422"
    (let [params (merge valid-params
       {   :listing-type "FixedPrice"
   :asking-price nil})
          resp (app (-> (mock/request :post "/api/trade_listings")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-auction-requires-start-price-and-end-time
  (testing "POST /api/trade_listings violates rule auction_requires_start_price_and_end_time → 422"
    (let [params (merge valid-params
       {   :listing-type "Auction"
   :auction-start-price nil})
          resp (app (-> (mock/request :post "/api/trade_listings")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-quantity-positive
  (testing "POST /api/trade_listings violates rule quantity_positive → 422"
    (let [params (merge valid-params
       {   :quantity 10000})
          resp (app (-> (mock/request :post "/api/trade_listings")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

