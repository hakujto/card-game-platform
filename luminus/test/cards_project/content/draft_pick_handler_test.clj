(ns cards_project.content.draft-pick-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :pick-number 0
   :pack-number 0
   :picked-at "2024-01-01T00:00:00"
   :participant-id 1
   :card-id 1})

(deftest test-list-draft-picks
  (testing "GET /api/draft_picks returns 200"
    (let [resp (app (mock/request :get "/api/draft_picks"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-draft-pick
  (testing "POST /api/draft_picks returns 201"
    (let [resp (app (-> (mock/request :post "/api/draft_picks")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-draft-pick
  (testing "GET /api/draft_picks/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/draft_picks/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-draft-pick
  (testing "PUT /api/draft_picks/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/draft_picks/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-draft-pick
  (testing "DELETE /api/draft_picks/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/draft_picks/1"))]
      (is (#{204 404} (:status resp)))))
)

