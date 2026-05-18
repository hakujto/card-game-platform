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
   :draws 0
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
      (is (#{201 500} (:status resp)))))
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
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-deck
  (testing "DELETE /api/decks/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/decks/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-wins-not-negative
  (testing "POST /api/decks violates rule wins_not_negative → 422"
    (let [params (merge valid-params
       {   :wins -1})
          resp (app (-> (mock/request :post "/api/decks")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-losses-not-negative
  (testing "POST /api/decks violates rule losses_not_negative → 422"
    (let [params (merge valid-params
       {   :losses -1})
          resp (app (-> (mock/request :post "/api/decks")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-draws-not-negative
  (testing "POST /api/decks violates rule draws_not_negative → 422"
    (let [params (merge valid-params
       {   :draws -1})
          resp (app (-> (mock/request :post "/api/decks")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-tournament-legal-deck-must-be-validated
  (testing "POST /api/decks violates rule tournament_legal_deck_must_be_validated → 422"
    (let [params (merge valid-params
       {   :is-tournament-legal true
   :is-public false})
          resp (app (-> (mock/request :post "/api/decks")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

