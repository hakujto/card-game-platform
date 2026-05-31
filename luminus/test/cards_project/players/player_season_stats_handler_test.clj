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

(deftest test-get-player-season-stats
  (testing "GET /api/player_season_statses/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/player_season_statses/1"))]
      (is (#{200 404} (:status resp)))))
)

