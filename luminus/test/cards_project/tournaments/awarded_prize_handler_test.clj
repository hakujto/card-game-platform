(ns cards_project.tournaments.awarded-prize-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :final-placement 0
   :awarded-at "2024-01-01T00:00:00"
   :claimed true
   :prize-id 1
   :player-id 1})

(deftest test-list-awarded-prizes
  (testing "GET /api/awarded_prizes returns 200"
    (let [resp (app (mock/request :get "/api/awarded_prizes"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-awarded-prize
  (testing "POST /api/awarded_prizes returns 201"
    (let [resp (app (-> (mock/request :post "/api/awarded_prizes")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-awarded-prize
  (testing "GET /api/awarded_prizes/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/awarded_prizes/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-awarded-prize
  (testing "PUT /api/awarded_prizes/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/awarded_prizes/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-awarded-prize
  (testing "DELETE /api/awarded_prizes/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/awarded_prizes/1"))]
      (is (#{204 404} (:status resp)))))
)

