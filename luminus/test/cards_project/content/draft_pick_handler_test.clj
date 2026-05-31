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

(deftest test-get-draft-pick
  (testing "GET /api/draft_picks/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/draft_picks/1"))]
      (is (#{200 404} (:status resp)))))
)

