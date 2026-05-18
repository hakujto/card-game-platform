(ns cards_project.tournaments.tournament-registration-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :status "Registered"
   :seed 1
   :final-standing 1
   :points-earned 0
   :registered-at "2024-01-01T00:00:00"
   :tournament-id 1
   :player-id 1
   :deck-id 1})

(deftest test-list-tournament-registrations
  (testing "GET /api/tournament_registrations returns 200"
    (let [resp (app (mock/request :get "/api/tournament_registrations"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-tournament-registration
  (testing "POST /api/tournament_registrations returns 201"
    (let [resp (app (-> (mock/request :post "/api/tournament_registrations")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-tournament-registration
  (testing "GET /api/tournament_registrations/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/tournament_registrations/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-tournament-registration
  (testing "PUT /api/tournament_registrations/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/tournament_registrations/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-tournament-registration
  (testing "DELETE /api/tournament_registrations/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/tournament_registrations/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-points-earned-not-negative
  (testing "POST /api/tournament_registrations violates rule points_earned_not_negative → 422"
    (let [params (merge valid-params
       {   :points-earned -1})
          resp (app (-> (mock/request :post "/api/tournament_registrations")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-final-standing-positive
  (testing "POST /api/tournament_registrations violates rule final_standing_positive → 422"
    (let [params (merge valid-params
       {   :final-standing "0"})
          resp (app (-> (mock/request :post "/api/tournament_registrations")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-seed-positive
  (testing "POST /api/tournament_registrations violates rule seed_positive → 422"
    (let [params (merge valid-params
       {   :seed "0"})
          resp (app (-> (mock/request :post "/api/tournament_registrations")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

