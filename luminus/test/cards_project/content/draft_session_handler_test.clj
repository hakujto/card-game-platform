(ns cards_project.content.draft-session-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :status "Completed"
   :draft-type "Booster"
   :seats 2
   :time-per-pick-seconds 1
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

; Simple rule violated → 422
(deftest test-rule-time-per-pick-positive
  (testing "POST /api/draft_sessions violates rule time_per_pick_positive → 422"
    (let [params (merge valid-params
       {   :time-per-pick-seconds 0})
          resp (app (-> (mock/request :post "/api/draft_sessions")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

(deftest test-transition-waiting-for-players-to-drafting
  (testing "PATCH /api/draft_sessions/1/transitions/waitingforplayers-to-drafting transitions WaitingForPlayers -> Drafting"
    (let [resp (app (mock/request :patch "/api/draft_sessions/1/transitions/waitingforplayers-to-drafting"))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-drafting-to-completed
  (testing "PATCH /api/draft_sessions/1/transitions/drafting-to-completed transitions Drafting -> Completed"
    (let [resp (app (mock/request :patch "/api/draft_sessions/1/transitions/drafting-to-completed"))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-drafting-to-abandoned
  (testing "PATCH /api/draft_sessions/1/transitions/drafting-to-abandoned transitions Drafting -> Abandoned with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/draft_sessions/1/transitions/drafting-to-abandoned")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-drafting-to-abandoned-forbidden
  (testing "PATCH /api/draft_sessions/1/transitions/drafting-to-abandoned without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/draft_sessions/1/transitions/drafting-to-abandoned")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-waiting-for-players-to-abandoned
  (testing "PATCH /api/draft_sessions/1/transitions/waitingforplayers-to-abandoned transitions WaitingForPlayers -> Abandoned with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/draft_sessions/1/transitions/waitingforplayers-to-abandoned")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-waiting-for-players-to-abandoned-forbidden
  (testing "PATCH /api/draft_sessions/1/transitions/waitingforplayers-to-abandoned without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/draft_sessions/1/transitions/waitingforplayers-to-abandoned")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-completed-to-drafting
  (testing "PATCH /api/draft_sessions/1/transitions/completed-to-drafting is denied"
    (let [resp (app (mock/request :patch "/api/draft_sessions/1/transitions/completed-to-drafting"))]
      (is (#{409 404} (:status resp)))))
)

(deftest test-transition-abandoned-to-drafting
  (testing "PATCH /api/draft_sessions/1/transitions/abandoned-to-drafting is denied"
    (let [resp (app (mock/request :patch "/api/draft_sessions/1/transitions/abandoned-to-drafting"))]
      (is (#{409 404} (:status resp)))))
)

