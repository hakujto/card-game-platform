(ns cards_project.cards.card-set-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :code "test"
   :release-date "2024-01-01"
   :rotation-date "2024-01-02"
   :set-type "Core"
   :total-cards 1
   :is-rotated true})

(deftest test-list-card-sets
  (testing "GET /api/card_sets returns 200"
    (let [resp (app (mock/request :get "/api/card_sets"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-card-set
  (testing "POST /api/card_sets returns 201"
    (let [resp (app (-> (mock/request :post "/api/card_sets")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-card-set
  (testing "GET /api/card_sets/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/card_sets/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-card-set
  (testing "PUT /api/card_sets/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/card_sets/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-card-set
  (testing "DELETE /api/card_sets/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/card_sets/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-total-cards-positive
  (testing "POST /api/card_sets violates rule total_cards_positive → 422"
    (let [params (merge valid-params
       {   :total-cards "0"})
          resp (app (-> (mock/request :post "/api/card_sets")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-rotation-date-after-release
  (testing "POST /api/card_sets violates rule rotation_date_after_release → 422"
    (let [params (merge valid-params
       {   :rotation-date "2023-12-31"
   :release-date "2024-01-01"})
          resp (app (-> (mock/request :post "/api/card_sets")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-rotated-set-has-rotation-date
  (testing "POST /api/card_sets violates rule rotated_set_has_rotation_date → 422"
    (let [params (merge valid-params
       {   :is-rotated true
   :rotation-date nil})
          resp (app (-> (mock/request :post "/api/card_sets")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

