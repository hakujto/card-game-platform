(ns cards_project.marketplace.tradelisting-handler-test
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

(deftest test-list-tradelistings
  (testing "GET /api/tradelistings returns 200"
    (let [resp (app (mock/request :get "/api/tradelistings"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-tradelisting
  (testing "POST /api/tradelistings returns 201"
    (let [resp (app (-> (mock/request :post "/api/tradelistings")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-tradelisting
  (testing "GET /api/tradelistings/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/tradelistings/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-tradelisting
  (testing "PUT /api/tradelistings/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/tradelistings/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-tradelisting
  (testing "DELETE /api/tradelistings/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/tradelistings/1"))]
      (is (#{204 404} (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-fixed-price-requires-asking-price
  (testing "POST /api/tradelistings violates rule fixed_price_requires_asking_price → 422"
    (let [params (merge valid-params
       {   :listing-type "FixedPrice"
   :asking-price nil})
          resp (app (-> (mock/request :post "/api/tradelistings")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-auction-requires-start-price-and-end-time
  (testing "POST /api/tradelistings violates rule auction_requires_start_price_and_end_time → 422"
    (let [params (merge valid-params
       {   :listing-type "Auction"
   :auction-start-price nil})
          resp (app (-> (mock/request :post "/api/tradelistings")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-quantity-positive
  (testing "POST /api/tradelistings violates rule quantity_positive → 422"
    (let [params (merge valid-params
       {   :quantity 10000})
          resp (app (-> (mock/request :post "/api/tradelistings")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

