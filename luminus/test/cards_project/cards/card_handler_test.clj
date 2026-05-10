(ns cards_project.cards.card-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :card-type "Creature"
   :rarity "Common"
   :mana-cost 0
   :mana-colors "White"
   :description "test"
   :legal-formats "Standard"
   :is-banned true
   :is-restricted true
   :power-level 0
   :set-id 1})

(deftest test-list-cards
  (testing "GET /api/cards returns 200"
    (let [resp (app (mock/request :get "/api/cards"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-card
  (testing "POST /api/cards returns 201"
    (let [resp (app (-> (mock/request :post "/api/cards")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-card
  (testing "GET /api/cards/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/cards/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-card
  (testing "PUT /api/cards/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/cards/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-card
  (testing "DELETE /api/cards/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/cards/1"))]
      (is (#{204 404} (:status resp)))))
)

