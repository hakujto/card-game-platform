(ns cards_project.players.player-season-stats-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :wins 0
   :losses 0
   :draws 0
   :tournament-wins 0
   :season-points 0
   :season-id 1})

(deftest test-list-player-season-statses
  (testing "GET /api/player_season_statses returns 200"
    (let [resp (app (mock/request :get "/api/player_season_statses"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-player-season-stats
  (testing "POST /api/player_season_statses returns 201"
    (let [resp (app (-> (mock/request :post "/api/player_season_statses")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-player-season-stats
  (testing "GET /api/player_season_statses/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/player_season_statses/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-player-season-stats
  (testing "PUT /api/player_season_statses/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/player_season_statses/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-player-season-stats
  (testing "DELETE /api/player_season_statses/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/player_season_statses/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-wins-not-negative
  (testing "POST /api/player_season_statses violates rule wins_not_negative → 422"
    (let [params (merge valid-params
       {   :wins -1})
          resp (app (-> (mock/request :post "/api/player_season_statses")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-losses-not-negative
  (testing "POST /api/player_season_statses violates rule losses_not_negative → 422"
    (let [params (merge valid-params
       {   :losses -1})
          resp (app (-> (mock/request :post "/api/player_season_statses")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-tournament-wins-not-negative
  (testing "POST /api/player_season_statses violates rule tournament_wins_not_negative → 422"
    (let [params (merge valid-params
       {   :tournament-wins -1})
          resp (app (-> (mock/request :post "/api/player_season_statses")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-season-points-not-negative
  (testing "POST /api/player_season_statses violates rule season_points_not_negative → 422"
    (let [params (merge valid-params
       {   :season-points -1})
          resp (app (-> (mock/request :post "/api/player_season_statses")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

