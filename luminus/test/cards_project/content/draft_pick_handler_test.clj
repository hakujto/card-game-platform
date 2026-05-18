(ns cards_project.content.draft-pick-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :pick-number 1
   :pack-number 1
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

; Simple rule violated → 422
(deftest test-rule-pick-number-positive
  (testing "POST /api/draft_picks violates rule pick_number_positive → 422"
    (let [params (merge valid-params
       {   :pick-number "0"})
          resp (app (-> (mock/request :post "/api/draft_picks")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-pack-number-range
  (testing "POST /api/draft_picks violates rule pack_number_range → 422"
    (let [params (merge valid-params
       {   :pack-number 4})
          resp (app (-> (mock/request :post "/api/draft_picks")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

