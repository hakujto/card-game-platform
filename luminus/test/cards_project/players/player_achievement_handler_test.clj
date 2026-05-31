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

(deftest test-get-player-achievement
  (testing "GET /api/player_achievements/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/player_achievements/1"))]
      (is (#{200 404} (:status resp)))))
)

