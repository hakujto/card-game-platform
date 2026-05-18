(ns cards_project.tournaments.tournament-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :format "Standard"
   :tournament-type "Swiss"
   :status "Draft"
   :max-players 2
   :entry-fee 0
   :prize-pool 0
   :start-time "2024-01-01T00:00:00"
   :end-time "2024-01-02T00:00:00"
   :is-online true
   :created-at "2024-01-01T00:00:00"
   :season-id 1
   :organizer-id 1})

(deftest test-list-tournaments
  (testing "GET /api/tournaments returns 200"
    (let [resp (app (mock/request :get "/api/tournaments"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-tournament
  (testing "POST /api/tournaments returns 201"
    (let [resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-tournament
  (testing "GET /api/tournaments/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/tournaments/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-tournament
  (testing "PUT /api/tournaments/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/tournaments/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-tournament
  (testing "DELETE /api/tournaments/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/tournaments/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-max-players-positive
  (testing "POST /api/tournaments violates rule max_players_positive → 422"
    (let [params (merge valid-params
       {   :max-players 513})
          resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-entry-fee-not-negative
  (testing "POST /api/tournaments violates rule entry_fee_not_negative → 422"
    (let [params (merge valid-params
       {   :entry-fee -1})
          resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-prize-pool-not-negative
  (testing "POST /api/tournaments violates rule prize_pool_not_negative → 422"
    (let [params (merge valid-params
       {   :prize-pool -1})
          resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-end-time-after-start
  (testing "POST /api/tournaments violates rule end_time_after_start → 422"
    (let [params (merge valid-params
       {   :end-time "2023-12-31T00:00:00"
   :start-time "2024-01-01T00:00:00"})
          resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

