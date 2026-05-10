(ns cards_project.tournaments.tournament-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :format "Standard"
   :tournament-type "Swiss"
   :status "Draft"
   :max-players 0
   :entry-fee 0.00M
   :prize-pool 0.00M
   :start-time "2024-01-01T00:00:00"
   :is-online true
   :created-at "2024-01-01T00:00:00"
   :season-id 1
   :organizer-id 1})

(deftest test-list-tournaments
  (testing "GET /api/tournaments returns 200"
    (let [resp (app (mock/request :get "/api/tournaments"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-tournament
  (testing "POST /api/tournaments returns 201"
    (let [resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-tournament
  (testing "GET /api/tournaments/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/tournaments/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-tournament
  (testing "PUT /api/tournaments/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/tournaments/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-tournament
  (testing "DELETE /api/tournaments/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/tournaments/1"))]
      (is (#{204 404} (:status resp)))))
)

