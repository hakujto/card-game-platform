(ns cards_project.tournaments.game-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :game-number 0
   :match-id 1})

(deftest test-list-games
  (testing "GET /api/games returns 200"
    (let [resp (app (mock/request :get "/api/games"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-game
  (testing "POST /api/games returns 201"
    (let [resp (app (-> (mock/request :post "/api/games")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-game
  (testing "GET /api/games/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/games/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-game
  (testing "PUT /api/games/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/games/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-game
  (testing "DELETE /api/games/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/games/1"))]
      (is (#{204 404} (:status resp)))))
)

