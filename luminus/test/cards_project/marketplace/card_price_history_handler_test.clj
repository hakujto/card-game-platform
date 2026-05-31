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

(deftest test-get-card-price-history
  (testing "GET /api/card_price_histories/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/card_price_histories/1"))]
      (is (#{200 404} (:status resp)))))
)

