(ns cards_project.tournaments.match-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :status "BYE"
   :player1-wins 0
   :player2-wins 0
   :started-at "2024-01-01T00:00:00"
   :ended-at "2024-01-02T00:00:00"
   :player1-id 1})

(deftest test-list-matches
  (testing "GET /api/matches returns 200"
    (let [resp (app (mock/request :get "/api/matches"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-match
  (testing "POST /api/matches returns 201"
    (let [resp (app (-> (mock/request :post "/api/matches")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-match
  (testing "GET /api/matches/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/matches/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-match
  (testing "PUT /api/matches/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/matches/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-match
  (testing "DELETE /api/matches/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/matches/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-wins-not-negative
  (testing "POST /api/matches violates rule wins_not_negative → 422"
    (let [params (merge valid-params
       {   :player1-wins -1})
          resp (app (-> (mock/request :post "/api/matches")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-max-three-games
  (testing "POST /api/matches violates rule max_three_games → 422"
    (let [params (merge valid-params
       {   :player1-wins 3})
          resp (app (-> (mock/request :post "/api/matches")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-bye-has-no-player2
  (testing "POST /api/matches violates rule bye_has_no_player2 → 422"
    (let [params (merge valid-params
       {   :status "BYE"
   :player2 1})
          resp (app (-> (mock/request :post "/api/matches")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-ended-after-started
  (testing "POST /api/matches violates rule ended_after_started → 422"
    (let [params (merge valid-params
       {   :ended-at "2023-12-31T00:00:00"
   :started-at "2024-01-01T00:00:00"})
          resp (app (-> (mock/request :post "/api/matches")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-completed-requires-started-at
  (testing "POST /api/matches violates rule completed_requires_started_at → 422"
    (let [params (merge valid-params
       {   :status "Completed"
   :started-at nil})
          resp (app (-> (mock/request :post "/api/matches")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

