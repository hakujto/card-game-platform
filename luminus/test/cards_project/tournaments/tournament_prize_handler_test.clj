(ns cards_project.tournaments.tournament-prize-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :placement-from 0
   :placement-to 0
   :prize-type "Currency"
   :amount 0.00M
   :season-points 0
   :tournament-id 1})

(deftest test-list-tournament-prizes
  (testing "GET /api/tournament_prizes returns 200"
    (let [resp (app (mock/request :get "/api/tournament_prizes"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-tournament-prize
  (testing "POST /api/tournament_prizes returns 201"
    (let [resp (app (-> (mock/request :post "/api/tournament_prizes")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-tournament-prize
  (testing "GET /api/tournament_prizes/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/tournament_prizes/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-tournament-prize
  (testing "PUT /api/tournament_prizes/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/tournament_prizes/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-tournament-prize
  (testing "DELETE /api/tournament_prizes/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/tournament_prizes/1"))]
      (is (#{204 404} (:status resp)))))
)

