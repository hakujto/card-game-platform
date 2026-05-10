(ns cards_project.content.draft-participant-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :seat-number 0
   :joined-at "2024-01-01T00:00:00"
   :player-id 1})

(deftest test-list-draft-participants
  (testing "GET /api/draft_participants returns 200"
    (let [resp (app (mock/request :get "/api/draft_participants"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-draft-participant
  (testing "POST /api/draft_participants returns 201"
    (let [resp (app (-> (mock/request :post "/api/draft_participants")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-draft-participant
  (testing "GET /api/draft_participants/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/draft_participants/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-draft-participant
  (testing "PUT /api/draft_participants/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/draft_participants/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-draft-participant
  (testing "DELETE /api/draft_participants/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/draft_participants/1"))]
      (is (#{204 404} (:status resp)))))
)

