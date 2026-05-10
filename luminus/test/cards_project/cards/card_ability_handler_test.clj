(ns cards_project.cards.card-ability-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :ability-type "Keyword"
   :ability-text "test"
   :card-id 1})

(deftest test-list-card-abilities
  (testing "GET /api/card_abilities returns 200"
    (let [resp (app (mock/request :get "/api/card_abilities"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-card-ability
  (testing "POST /api/card_abilities returns 201"
    (let [resp (app (-> (mock/request :post "/api/card_abilities")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-card-ability
  (testing "GET /api/card_abilities/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/card_abilities/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-card-ability
  (testing "PUT /api/card_abilities/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/card_abilities/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-card-ability
  (testing "DELETE /api/card_abilities/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/card_abilities/1"))]
      (is (#{204 404} (:status resp)))))
)

