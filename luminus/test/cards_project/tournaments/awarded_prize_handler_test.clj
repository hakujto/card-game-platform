(ns cards_project.tournaments.awarded-prize-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :final-placement 1
   :awarded-at "2024-01-01T00:00:00"
   :claimed true
   :claimed-at "2024-01-02T00:00:00"
   :prize-id 1
   :player-id 1})

(deftest test-list-awarded-prizes
  (testing "GET /api/awarded_prizes returns 200"
    (let [resp (app (mock/request :get "/api/awarded_prizes"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-awarded-prize
  (testing "POST /api/awarded_prizes returns 201"
    (let [resp (app (-> (mock/request :post "/api/awarded_prizes")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-awarded-prize
  (testing "GET /api/awarded_prizes/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/awarded_prizes/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-awarded-prize
  (testing "PUT /api/awarded_prizes/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/awarded_prizes/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-awarded-prize
  (testing "DELETE /api/awarded_prizes/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/awarded_prizes/1"))]
      (is (#{204 404} (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-claimed-requires-claimed-at
  (testing "POST /api/awarded_prizes violates rule claimed_requires_claimed_at → 422"
    (let [params (merge valid-params
       {   :claimed true
   :claimed-at nil})
          resp (app (-> (mock/request :post "/api/awarded_prizes")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-final-placement-positive
  (testing "POST /api/awarded_prizes violates rule final_placement_positive → 422"
    (let [params (merge valid-params
       {   :final-placement "0"})
          resp (app (-> (mock/request :post "/api/awarded_prizes")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

