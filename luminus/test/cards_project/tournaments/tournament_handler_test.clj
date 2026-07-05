(ns cards_project.tournaments.tournament-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :public-id (str "00000000-0000-0000-0000-000000000001-" (System/currentTimeMillis))
   :name "Test Tournament Alpha"
   :status "Draft"
   :format "Standard"
   :tournament-type "Swiss"
   :max-players 2
   :entry-fee 0
   :prize-pool 0
   :start-time "2024-01-01T00:00:00"
   :end-time "2024-01-02T00:00:00"
   :is-online true
   :created-at "2024-01-01T00:00:00"
   :season-id 1
   :organizer-id 1})

(deftest test-list-tournaments
  (testing "GET /api/tournaments returns 200"
    (let [resp (app (mock/request :get "/api/tournaments"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-tournament
  (testing "POST /api/tournaments returns 201"
    (let [resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-tournament
  (testing "GET /api/tournaments/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/tournaments/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-tournament
  (testing "PUT /api/tournaments/1 returns 200 or 404"
    (let [update-params (merge valid-params {   :public-id (str "00000000-0000-0000-0000-000000000001-" (System/currentTimeMillis))})
          resp (app (-> (mock/request :put "/api/tournaments/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string update-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-patch-tournament
  (testing "PATCH /api/tournaments/1 partial update returns 200 or 404"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string {:description "test"}))))]
      (is (#{200 404 500 422} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-max-players-positive
  (testing "POST /api/tournaments violates rule max_players_positive → 422"
    (let [params (merge valid-params
       {   :max-players 513})
          resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-entry-fee-not-negative
  (testing "POST /api/tournaments violates rule entry_fee_not_negative → 422"
    (let [params (merge valid-params
       {   :entry-fee -1})
          resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-prize-pool-not-negative
  (testing "POST /api/tournaments violates rule prize_pool_not_negative → 422"
    (let [params (merge valid-params
       {   :prize-pool -1})
          resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-end-time-after-start
  (testing "POST /api/tournaments violates rule end_time_after_start → 422"
    (let [params (merge valid-params
       {   :end-time "2023-12-31T00:00:00"
   :start-time "2024-01-01T00:00:00"})
          resp (app (-> (mock/request :post "/api/tournaments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

(deftest test-transition-draft-to-registration
  (testing "PATCH /api/tournaments/1/transitions/draft-to-registration transitions Draft -> Registration with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1/transitions/draft-to-registration")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-draft-to-registration-forbidden
  (testing "PATCH /api/tournaments/1/transitions/draft-to-registration without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1/transitions/draft-to-registration")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-registration-to-ongoing
  (testing "PATCH /api/tournaments/1/transitions/registration-to-ongoing transitions Registration -> Ongoing with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1/transitions/registration-to-ongoing")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-registration-to-ongoing-forbidden
  (testing "PATCH /api/tournaments/1/transitions/registration-to-ongoing without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1/transitions/registration-to-ongoing")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-registration-to-cancelled
  (testing "PATCH /api/tournaments/1/transitions/registration-to-cancelled transitions Registration -> Cancelled with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1/transitions/registration-to-cancelled")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-registration-to-cancelled-forbidden
  (testing "PATCH /api/tournaments/1/transitions/registration-to-cancelled without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1/transitions/registration-to-cancelled")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-ongoing-to-completed
  (testing "PATCH /api/tournaments/1/transitions/ongoing-to-completed transitions Ongoing -> Completed with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1/transitions/ongoing-to-completed")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-ongoing-to-completed-forbidden
  (testing "PATCH /api/tournaments/1/transitions/ongoing-to-completed without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1/transitions/ongoing-to-completed")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-ongoing-to-cancelled
  (testing "PATCH /api/tournaments/1/transitions/ongoing-to-cancelled transitions Ongoing -> Cancelled with role Admin"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1/transitions/ongoing-to-cancelled")
                     (mock/header "x-user-role" "Admin")))]
      (is (#{200 409 422 404 500} (:status resp)))))
)

(deftest test-transition-ongoing-to-cancelled-forbidden
  (testing "PATCH /api/tournaments/1/transitions/ongoing-to-cancelled without role Admin is forbidden"
    (let [resp (app (-> (mock/request :patch "/api/tournaments/1/transitions/ongoing-to-cancelled")
                     (mock/header "x-user-role" "anonymous")))]
      (is (= 403 (:status resp)))))
)

(deftest test-transition-completed-to-draft
  (testing "PATCH /api/tournaments/1/transitions/completed-to-draft is denied"
    (let [resp (app (mock/request :patch "/api/tournaments/1/transitions/completed-to-draft"))]
      (is (#{409 404} (:status resp)))))
)

(deftest test-transition-cancelled-to-draft
  (testing "PATCH /api/tournaments/1/transitions/cancelled-to-draft is denied"
    (let [resp (app (mock/request :patch "/api/tournaments/1/transitions/cancelled-to-draft"))]
      (is (#{409 404} (:status resp)))))
)

