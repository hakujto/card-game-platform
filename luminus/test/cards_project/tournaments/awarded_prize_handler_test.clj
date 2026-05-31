(ns cards_project.tournaments.awarded-prize-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :final-placement 1
   :awarded-at "2024-01-01T00:00:00"
   :claimed true
   :claimed-at "2024-01-02T00:00:00"
   :prize-id 1
   :player-id 1})

(deftest test-list-awarded-prizes
  (testing "GET /api/awarded_prizes returns 200"
    (let [resp (app (mock/request :get "/api/awarded_prizes"))]
      (is (= 200 (:status resp)))))
)

(deftest test-get-awarded-prize
  (testing "GET /api/awarded_prizes/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/awarded_prizes/1"))]
      (is (#{200 404} (:status resp)))))
)

