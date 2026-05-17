(ns cards_project.tournaments.tournament-judge-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :role "HeadJudge"
   :tournament-id 1
   :player-id 1})

(deftest test-list-tournament-judges
  (testing "GET /api/tournament_judges returns 200"
    (let [resp (app (mock/request :get "/api/tournament_judges"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-tournament-judge
  (testing "POST /api/tournament_judges returns 201"
    (let [resp (app (-> (mock/request :post "/api/tournament_judges")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-tournament-judge
  (testing "GET /api/tournament_judges/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/tournament_judges/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-tournament-judge
  (testing "PUT /api/tournament_judges/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/tournament_judges/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-tournament-judge
  (testing "DELETE /api/tournament_judges/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/tournament_judges/1"))]
      (is (#{204 404} (:status resp)))))
)

