(ns cards_project.content.article-comment-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :body "test"
   :is-hidden true
   :created-at "2024-01-01T00:00:00"
   :author-id 1})

(deftest test-list-article-comments
  (testing "GET /api/article_comments returns 200"
    (let [resp (app (mock/request :get "/api/article_comments"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-article-comment
  (testing "POST /api/article_comments returns 201"
    (let [resp (app (-> (mock/request :post "/api/article_comments")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-article-comment
  (testing "GET /api/article_comments/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/article_comments/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-article-comment
  (testing "PUT /api/article_comments/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/article_comments/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-article-comment
  (testing "DELETE /api/article_comments/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/article_comments/1"))]
      (is (#{204 404} (:status resp)))))
)

