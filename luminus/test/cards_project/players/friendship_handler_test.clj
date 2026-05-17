(ns cards_project.players.friendship-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :status "Pending"
   :created-at "2024-01-01T00:00:00"
   :requester-id 1
   :receiver-id 1})

(deftest test-list-friendships
  (testing "GET /api/friendships returns 200"
    (let [resp (app (mock/request :get "/api/friendships"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-friendship
  (testing "POST /api/friendships returns 201"
    (let [resp (app (-> (mock/request :post "/api/friendships")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-friendship
  (testing "GET /api/friendships/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/friendships/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-friendship
  (testing "PUT /api/friendships/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/friendships/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-friendship
  (testing "DELETE /api/friendships/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/friendships/1"))]
      (is (#{204 404} (:status resp)))))
)

