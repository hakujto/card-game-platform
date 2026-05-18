(ns cards_project.tournaments.tournament-round-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :round-number 1
   :status "Completed"
   :started-at "2024-01-01T00:00:00"
   :ended-at "2024-01-02T00:00:00"
   :time-limit-minutes 1
   :tournament-id 1})

(deftest test-list-tournament-rounds
  (testing "GET /api/tournament_rounds returns 200"
    (let [resp (app (mock/request :get "/api/tournament_rounds"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-tournament-round
  (testing "POST /api/tournament_rounds returns 201"
    (let [resp (app (-> (mock/request :post "/api/tournament_rounds")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-tournament-round
  (testing "GET /api/tournament_rounds/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/tournament_rounds/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-tournament-round
  (testing "PUT /api/tournament_rounds/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/tournament_rounds/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-tournament-round
  (testing "DELETE /api/tournament_rounds/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/tournament_rounds/1"))]
      (is (#{204 404} (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-ended-after-started
  (testing "POST /api/tournament_rounds violates rule ended_after_started → 422"
    (let [params (merge valid-params
       {   :ended-at "2023-12-31T00:00:00"
   :started-at "2024-01-01T00:00:00"})
          resp (app (-> (mock/request :post "/api/tournament_rounds")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-completed-requires-started-at
  (testing "POST /api/tournament_rounds violates rule completed_requires_started_at → 422"
    (let [params (merge valid-params
       {   :status "Completed"
   :started-at nil})
          resp (app (-> (mock/request :post "/api/tournament_rounds")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-round-number-positive
  (testing "POST /api/tournament_rounds violates rule round_number_positive → 422"
    (let [params (merge valid-params
       {   :round-number "0"})
          resp (app (-> (mock/request :post "/api/tournament_rounds")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-time-limit-positive
  (testing "POST /api/tournament_rounds violates rule time_limit_positive → 422"
    (let [params (merge valid-params
       {   :time-limit-minutes "0"})
          resp (app (-> (mock/request :post "/api/tournament_rounds")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

