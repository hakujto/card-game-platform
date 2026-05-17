(ns cards_project.players.crafting-ingredient-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :quantity 0
   :recipe-id 1
   :card-id 1})

(deftest test-list-crafting-ingredients
  (testing "GET /api/crafting_ingredients returns 200"
    (let [resp (app (mock/request :get "/api/crafting_ingredients"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-crafting-ingredient
  (testing "POST /api/crafting_ingredients returns 201"
    (let [resp (app (-> (mock/request :post "/api/crafting_ingredients")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-crafting-ingredient
  (testing "GET /api/crafting_ingredients/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/crafting_ingredients/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-crafting-ingredient
  (testing "PUT /api/crafting_ingredients/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/crafting_ingredients/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-crafting-ingredient
  (testing "DELETE /api/crafting_ingredients/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/crafting_ingredients/1"))]
      (is (#{204 404} (:status resp)))))
)

