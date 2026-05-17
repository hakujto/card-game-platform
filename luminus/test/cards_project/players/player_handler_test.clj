(ns cards_project.players.player-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :display-name 1
   :rank "Bronze"
   :rating 0
   :peak-rating 0
   :is-verified true
   :created-at "2024-01-01T00:00:00"})

(deftest test-list-players
  (testing "GET /api/players returns 200"
    (let [resp (app (mock/request :get "/api/players"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-player
  (testing "POST /api/players returns 201"
    (let [resp (app (-> (mock/request :post "/api/players")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-player
  (testing "GET /api/players/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/players/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-player
  (testing "PUT /api/players/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/players/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-player
  (testing "DELETE /api/players/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/players/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-rating-range
  (testing "POST /api/players violates rule rating_range → 422"
    (let [params (merge valid-params
       {   :rating 10000})
          resp (app (-> (mock/request :post "/api/players")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-peak-rating-gte-rating
  (testing "POST /api/players violates rule peak_rating_gte_rating → 422"
    (let [params (merge valid-params
       {   :peak-rating 0
   :rating 1})
          resp (app (-> (mock/request :post "/api/players")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

