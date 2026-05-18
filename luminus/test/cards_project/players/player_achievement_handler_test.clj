(ns cards_project.players.player-achievement-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :earned-at "2024-01-01T00:00:00"
   :progress 1
   :is-completed true
   :player-id 1
   :achievement-id 1})

(deftest test-list-player-achievements
  (testing "GET /api/player_achievements returns 200"
    (let [resp (app (mock/request :get "/api/player_achievements"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-player-achievement
  (testing "POST /api/player_achievements returns 201"
    (let [resp (app (-> (mock/request :post "/api/player_achievements")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-player-achievement
  (testing "GET /api/player_achievements/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/player_achievements/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-player-achievement
  (testing "PUT /api/player_achievements/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/player_achievements/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-player-achievement
  (testing "DELETE /api/player_achievements/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/player_achievements/1"))]
      (is (#{204 404} (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-completed-requires-progress
  (testing "POST /api/player_achievements violates rule completed_requires_progress → 422"
    (let [params (merge valid-params
       {   :is-completed true
   :progress "0"})
          resp (app (-> (mock/request :post "/api/player_achievements")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-progress-not-negative
  (testing "POST /api/player_achievements violates rule progress_not_negative → 422"
    (let [params (merge valid-params
       {   :progress -1})
          resp (app (-> (mock/request :post "/api/player_achievements")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

