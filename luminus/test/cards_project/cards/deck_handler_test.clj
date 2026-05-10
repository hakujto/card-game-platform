(ns cards_project.cards.deck-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :format "Standard"
   :is-public true
   :is-tournament-legal true
   :wins 0
   :losses 0
   :created-at "2024-01-01T00:00:00"
   :updated-at "2024-01-01T00:00:00"
   :player-id 1})

(deftest test-list-decks
  (testing "GET /api/decks returns 200"
    (let [resp (app (mock/request :get "/api/decks"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-deck
  (testing "POST /api/decks returns 201"
    (let [resp (app (-> (mock/request :post "/api/decks")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-deck
  (testing "GET /api/decks/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/decks/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-deck
  (testing "PUT /api/decks/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/decks/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-deck
  (testing "DELETE /api/decks/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/decks/1"))]
      (is (#{204 404} (:status resp)))))
)

