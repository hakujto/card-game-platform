(ns cards_project.players.achievement-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :description "test"
   :points 0
   :rarity "Common"
   :is-hidden true})

(deftest test-list-achievements
  (testing "GET /api/achievements returns 200"
    (let [resp (app (mock/request :get "/api/achievements"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-achievement
  (testing "POST /api/achievements returns 201"
    (let [resp (app (-> (mock/request :post "/api/achievements")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-achievement
  (testing "GET /api/achievements/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/achievements/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-achievement
  (testing "PUT /api/achievements/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/achievements/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-achievement
  (testing "DELETE /api/achievements/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/achievements/1"))]
      (is (#{204 404} (:status resp)))))
)

