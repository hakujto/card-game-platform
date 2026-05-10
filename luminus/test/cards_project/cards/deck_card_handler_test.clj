(ns cards_project.cards.deck-card-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :quantity 0
   :is-commander true
   :deck-id 1
   :card-id 1})

(deftest test-list-deck-cards
  (testing "GET /api/deck_cards returns 200"
    (let [resp (app (mock/request :get "/api/deck_cards"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-deck-card
  (testing "POST /api/deck_cards returns 201"
    (let [resp (app (-> (mock/request :post "/api/deck_cards")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-deck-card
  (testing "GET /api/deck_cards/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/deck_cards/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-deck-card
  (testing "PUT /api/deck_cards/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/deck_cards/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-deck-card
  (testing "DELETE /api/deck_cards/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/deck_cards/1"))]
      (is (#{204 404} (:status resp)))))
)

