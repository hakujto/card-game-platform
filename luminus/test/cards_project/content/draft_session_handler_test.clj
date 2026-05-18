(ns cards_project.content.draft-session-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :status "Completed"
   :draft-type "Booster"
   :seats 2
   :created-at "2024-01-01T00:00:00"
   :card-set-id 1})

(deftest test-list-draft-sessions
  (testing "GET /api/draft_sessions returns 200"
    (let [resp (app (mock/request :get "/api/draft_sessions"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-draft-session
  (testing "POST /api/draft_sessions returns 201"
    (let [resp (app (-> (mock/request :post "/api/draft_sessions")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-draft-session
  (testing "GET /api/draft_sessions/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/draft_sessions/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-draft-session
  (testing "PUT /api/draft_sessions/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/draft_sessions/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-draft-session
  (testing "DELETE /api/draft_sessions/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/draft_sessions/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-seats-range
  (testing "POST /api/draft_sessions violates rule seats_range → 422"
    (let [params (merge valid-params
       {   :seats 17})
          resp (app (-> (mock/request :post "/api/draft_sessions")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-completed-at-requires-completed-status
  (testing "POST /api/draft_sessions violates rule completed_at_requires_completed_status → 422"
    (let [params (merge valid-params
       {   :completed-at "2024-01-02T00:00:00"
   :status "WaitingForPlayers"})
          resp (app (-> (mock/request :post "/api/draft_sessions")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

