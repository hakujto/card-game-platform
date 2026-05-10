(ns cards_project.cards.deck-tag-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"})

(deftest test-list-deck-tags
  (testing "GET /api/deck_tags returns 200"
    (let [resp (app (mock/request :get "/api/deck_tags"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-deck-tag
  (testing "POST /api/deck_tags returns 201"
    (let [resp (app (-> (mock/request :post "/api/deck_tags")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-deck-tag
  (testing "GET /api/deck_tags/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/deck_tags/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-deck-tag
  (testing "PUT /api/deck_tags/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/deck_tags/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-deck-tag
  (testing "DELETE /api/deck_tags/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/deck_tags/1"))]
      (is (#{204 404} (:status resp)))))
)

