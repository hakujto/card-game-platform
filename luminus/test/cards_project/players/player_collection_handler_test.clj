(ns cards_project.players.player-collection-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :quantity 0
   :foil true
   :condition "Mint"
   :acquired-at "2024-01-01T00:00:00"
   :acquired-via "Purchase"
   :player-id 1
   :card-id 1})

(deftest test-list-player-collections
  (testing "GET /api/player_collections returns 200"
    (let [resp (app (mock/request :get "/api/player_collections"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-player-collection
  (testing "POST /api/player_collections returns 201"
    (let [resp (app (-> (mock/request :post "/api/player_collections")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-player-collection
  (testing "GET /api/player_collections/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/player_collections/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-player-collection
  (testing "PUT /api/player_collections/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/player_collections/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-player-collection
  (testing "DELETE /api/player_collections/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/player_collections/1"))]
      (is (#{204 404} (:status resp)))))
)

