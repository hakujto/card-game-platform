(ns cards_project.cards.card-set-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :code "test"
   :release-date "2024-01-01"
   :set-type "Core"
   :total-cards 0})

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

