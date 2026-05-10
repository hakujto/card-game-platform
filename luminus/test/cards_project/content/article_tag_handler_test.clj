(ns cards_project.content.article-tag-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :name "test"
   :slug "test"})

(deftest test-list-article-tags
  (testing "GET /api/article_tags returns 200"
    (let [resp (app (mock/request :get "/api/article_tags"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-article-tag
  (testing "POST /api/article_tags returns 201"
    (let [resp (app (-> (mock/request :post "/api/article_tags")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (= 201 (:status resp)))))
)

(deftest test-get-article-tag
  (testing "GET /api/article_tags/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/article_tags/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-article-tag
  (testing "PUT /api/article_tags/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/article_tags/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-delete-article-tag
  (testing "DELETE /api/article_tags/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/article_tags/1"))]
      (is (#{204 404} (:status resp)))))
)

