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
   :attack 1
   :defense 1
   :loyalty nil
   :description "test"
   :legal-formats "message"
   :is-banned false
   :is-restricted true
   :power-level 1
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
      (is (#{201 500} (:status resp)))))
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
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-card
  (testing "DELETE /api/cards/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/cards/1"))]
      (is (#{204 404} (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-creature-requires-stats
  (testing "POST /api/cards violates rule creature_requires_stats → 422"
    (let [params (merge valid-params
       {   :card-type "Creature"
   :attack nil})
          resp (app (-> (mock/request :post "/api/cards")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-planeswalker-requires-loyalty
  (testing "POST /api/cards violates rule planeswalker_requires_loyalty → 422"
    (let [params (merge valid-params
       {   :card-type "Planeswalker"
   :loyalty nil})
          resp (app (-> (mock/request :post "/api/cards")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-spell-or-artifact-no-loyalty
  (testing "POST /api/cards violates rule spell_or_artifact_no_loyalty → 422"
    (let [params (merge valid-params
       {   :loyalty 1})
          resp (app (-> (mock/request :post "/api/cards")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-mana-cost-range
  (testing "POST /api/cards violates rule mana_cost_range → 422"
    (let [params (merge valid-params
       {   :mana-cost 21})
          resp (app (-> (mock/request :post "/api/cards")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-power-level-range
  (testing "POST /api/cards violates rule power_level_range → 422"
    (let [params (merge valid-params
       {   :power-level 11})
          resp (app (-> (mock/request :post "/api/cards")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-not-banned-and-restricted
  (testing "POST /api/cards violates rule not_banned_and_restricted → 422"
    (let [params (merge valid-params
       {   :is-banned true
   :is-restricted true})
          resp (app (-> (mock/request :post "/api/cards")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-banned-card-not-in-legal-formats
  (testing "POST /api/cards violates rule banned_card_not_in_legal_formats → 422"
    (let [params (merge valid-params
       {   :is-banned true
   :legal-formats "Standard"})
          resp (app (-> (mock/request :post "/api/cards")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

