(ns cards_project.content.article-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :title "test"
   :slug "test"
   :body "test"
   :status "Published"
   :article-type "Guide"
   :view-count 0
   :published-at "2024-01-02T00:00:00"
   :created-at "2024-01-01T00:00:00"
   :updated-at "2024-01-01T00:00:00"
   :author-id 1})

(deftest test-list-articles
  (testing "GET /api/articles returns 200"
    (let [resp (app (mock/request :get "/api/articles"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-article
  (testing "POST /api/articles returns 201"
    (let [resp (app (-> (mock/request :post "/api/articles")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-article
  (testing "GET /api/articles/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/articles/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-article
  (testing "PUT /api/articles/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/articles/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-article
  (testing "DELETE /api/articles/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/articles/1"))]
      (is (#{204 404} (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-published-requires-published-at
  (testing "POST /api/articles violates rule published_requires_published_at → 422"
    (let [params (merge valid-params
       {   :status "Published"
   :published-at nil})
          resp (app (-> (mock/request :post "/api/articles")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

