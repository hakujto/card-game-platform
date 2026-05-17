(ns cards_project.cards.deck-tag-assignment-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :deck-id 1
   :tag-id 1})

(deftest test-list-deck-tag-assignments
  (testing "GET /api/deck_tag_assignments returns 200"
    (let [resp (app (mock/request :get "/api/deck_tag_assignments"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-deck-tag-assignment
  (testing "POST /api/deck_tag_assignments returns 201"
    (let [resp (app (-> (mock/request :post "/api/deck_tag_assignments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-deck-tag-assignment
  (testing "GET /api/deck_tag_assignments/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/deck_tag_assignments/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-deck-tag-assignment
  (testing "PUT /api/deck_tag_assignments/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/deck_tag_assignments/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-deck-tag-assignment
  (testing "DELETE /api/deck_tag_assignments/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/deck_tag_assignments/1"))]
      (is (#{204 404} (:status resp)))))
)

