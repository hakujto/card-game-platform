(ns cards_project.tournaments.season-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :start-date "2024-01-01"
   :end-date "2024-01-01"
   :format "Standard"
   :is-active true})

(deftest test-list-seasons
  (testing "GET /api/seasons returns 200"
    (let [resp (app (mock/request :get "/api/seasons"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-season
  (testing "POST /api/seasons returns 201"
    (let [resp (app (-> (mock/request :post "/api/seasons")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-season
  (testing "GET /api/seasons/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/seasons/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-season
  (testing "PUT /api/seasons/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/seasons/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-season
  (testing "DELETE /api/seasons/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/seasons/1"))]
      (is (#{204 404} (:status resp)))))
)

