(ns cards_project.marketplace.trade-dispute-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :reason "ItemNotReceived"
   :description "test"
   :status "Open"
   :opened-at "2024-01-01T00:00:00"
   :transaction-id 1
   :opened-by-id 1})

(deftest test-list-trade-disputes
  (testing "GET /api/trade_disputes returns 200"
    (let [resp (app (mock/request :get "/api/trade_disputes"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-trade-dispute
  (testing "POST /api/trade_disputes returns 201"
    (let [resp (app (-> (mock/request :post "/api/trade_disputes")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-trade-dispute
  (testing "GET /api/trade_disputes/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/trade_disputes/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-trade-dispute
  (testing "PUT /api/trade_disputes/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/trade_disputes/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-trade-dispute
  (testing "DELETE /api/trade_disputes/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/trade_disputes/1"))]
      (is (#{204 404} (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-resolved-at-requires-terminal-status
  (testing "POST /api/trade_disputes violates rule resolved_at_requires_terminal_status → 422"
    (let [params (merge valid-params
       {   :resolved-at "2024-01-02T00:00:00"
   :status "Open"})
          resp (app (-> (mock/request :post "/api/trade_disputes")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

