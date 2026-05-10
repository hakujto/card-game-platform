(ns cards_project.content.stream-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :title "test"
   :stream-url "https://example.com"
   :platform "Twitch"
   :status "Scheduled"
   :viewer-count-peak 0
   :scheduled-start "2024-01-01T00:00:00"
   :streamer-id 1})

(deftest test-list-streams
  (testing "GET /api/streams returns 200"
    (let [resp (app (mock/request :get "/api/streams"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-stream
  (testing "POST /api/streams returns 201"
    (let [resp (app (-> (mock/request :post "/api/streams")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-stream
  (testing "GET /api/streams/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/streams/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-stream
  (testing "PUT /api/streams/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/streams/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-stream
  (testing "DELETE /api/streams/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/streams/1"))]
      (is (#{204 404} (:status resp)))))
)

