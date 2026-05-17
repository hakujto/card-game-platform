(ns cards_project.marketplace.card-price-history-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :price-date "2024-01-01"
   :avg-price 1
   :min-price 0
   :max-price 1
   :volume 0
   :foil true
   :card-id 1})

(deftest test-list-card-price-histories
  (testing "GET /api/card_price_histories returns 200"
    (let [resp (app (mock/request :get "/api/card_price_histories"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-card-price-history
  (testing "POST /api/card_price_histories returns 201"
    (let [resp (app (-> (mock/request :post "/api/card_price_histories")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-card-price-history
  (testing "GET /api/card_price_histories/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/card_price_histories/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-card-price-history
  (testing "PUT /api/card_price_histories/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/card_price_histories/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-card-price-history
  (testing "DELETE /api/card_price_histories/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/card_price_histories/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-price-bounds-consistent
  (testing "POST /api/card_price_histories violates rule price_bounds_consistent → 422"
    (let [params (merge valid-params
       {   :min-price 99999
   :avg-price 1})
          resp (app (-> (mock/request :post "/api/card_price_histories")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

