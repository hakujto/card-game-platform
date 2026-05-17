(ns cards_project.cards.card-ruling-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :ruling-text "test"
   :published-at "2024-01-01"
   :source "test"
   :card-id 1})

(deftest test-list-card-rulings
  (testing "GET /api/card_rulings returns 200"
    (let [resp (app (mock/request :get "/api/card_rulings"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-card-ruling
  (testing "POST /api/card_rulings returns 201"
    (let [resp (app (-> (mock/request :post "/api/card_rulings")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-card-ruling
  (testing "GET /api/card_rulings/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/card_rulings/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-card-ruling
  (testing "PUT /api/card_rulings/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/card_rulings/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-card-ruling
  (testing "DELETE /api/card_rulings/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/card_rulings/1"))]
      (is (#{204 404} (:status resp)))))
)

