(ns cards_project.marketplace.product-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :product-type "SingleCard"
   :price "0.00"
   :stock 0
   :active true
   :discount-percent 0
   :featured true})

(deftest test-list-products
  (testing "GET /api/products returns 200"
    (let [resp (app (mock/request :get "/api/products"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-product
  (testing "POST /api/products returns 201"
    (let [resp (app (-> (mock/request :post "/api/products")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-product
  (testing "GET /api/products/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/products/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-product
  (testing "PUT /api/products/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/products/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-product
  (testing "DELETE /api/products/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/products/1"))]
      (is (#{204 404} (:status resp)))))
)

