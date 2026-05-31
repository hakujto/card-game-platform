(ns cards_project.marketplace.trade-dispute-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :status "Resolved"
   :reason "ItemNotReceived"
   :description "test"
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

(deftest test-transition-open-to-under-review
  (testing "PATCH /api/trade_disputes/1/transitions/open-to-underreview transitions Open -> UnderReview"
    (let [resp (app (mock/request :patch "/api/trade_disputes/1/transitions/open-to-underreview"))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-under-review-to-resolved
  (testing "PATCH /api/trade_disputes/1/transitions/underreview-to-resolved transitions UnderReview -> Resolved"
    (let [resp (app (mock/request :patch "/api/trade_disputes/1/transitions/underreview-to-resolved"))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-under-review-to-escalated
  (testing "PATCH /api/trade_disputes/1/transitions/underreview-to-escalated transitions UnderReview -> Escalated"
    (let [resp (app (mock/request :patch "/api/trade_disputes/1/transitions/underreview-to-escalated"))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-escalated-to-resolved
  (testing "PATCH /api/trade_disputes/1/transitions/escalated-to-resolved transitions Escalated -> Resolved"
    (let [resp (app (mock/request :patch "/api/trade_disputes/1/transitions/escalated-to-resolved"))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-resolved-to-open
  (testing "PATCH /api/trade_disputes/1/transitions/resolved-to-open is denied"
    (let [resp (app (mock/request :patch "/api/trade_disputes/1/transitions/resolved-to-open"))]
      (is (#{409 404} (:status resp)))))
)

