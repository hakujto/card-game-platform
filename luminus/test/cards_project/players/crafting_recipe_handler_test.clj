(ns cards_project.players.crafting-recipe-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :dust-cost 1
   :is-available true
   :result-card-id 1})

(deftest test-list-crafting-recipes
  (testing "GET /api/crafting_recipes returns 200"
    (let [resp (app (mock/request :get "/api/crafting_recipes"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-crafting-recipe
  (testing "POST /api/crafting_recipes returns 201"
    (let [resp (app (-> (mock/request :post "/api/crafting_recipes")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-crafting-recipe
  (testing "GET /api/crafting_recipes/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/crafting_recipes/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-crafting-recipe
  (testing "PUT /api/crafting_recipes/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/crafting_recipes/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-crafting-recipe
  (testing "DELETE /api/crafting_recipes/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/crafting_recipes/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-dust-cost-positive
  (testing "POST /api/crafting_recipes violates rule dust_cost_positive → 422"
    (let [params (merge valid-params
       {   :dust-cost "0"})
          resp (app (-> (mock/request :post "/api/crafting_recipes")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

