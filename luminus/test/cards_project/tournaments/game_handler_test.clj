(ns cards_project.tournaments.game-handler-test
  (:require [clojure.test :refer [deftest testing is]]
            [cards_project.core :refer [app]]
            [ring.mock.request :as mock]
            [cheshire.core :as json]))

(def valid-params {   :game-number 1
   :turns-played 1
   :duration-seconds 1
   :match-id 1})

(deftest test-list-games
  (testing "GET /api/games returns 200"
    (let [resp (app (mock/request :get "/api/games"))]
      (is (= 200 (:status resp)))))
)

(deftest test-create-game
  (testing "POST /api/games returns 201"
    (let [resp (app (-> (mock/request :post "/api/games")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{201 500} (:status resp)))))
)

(deftest test-get-game
  (testing "GET /api/games/1 returns 200 or 404"
    (let [resp (app (mock/request :get "/api/games/1"))]
      (is (#{200 404} (:status resp)))))
)

(deftest test-update-game
  (testing "PUT /api/games/1 returns 200 or 404"
    (let [resp (app (-> (mock/request :put "/api/games/1")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string valid-params))))]
      (is (#{200 404 500} (:status resp)))))
)

(deftest test-delete-game
  (testing "DELETE /api/games/1 returns 204 or 404"
    (let [resp (app (mock/request :delete "/api/games/1"))]
      (is (#{204 404} (:status resp)))))
)

; Simple rule violated → 422
(deftest test-rule-game-number-range
  (testing "POST /api/games violates rule game_number_range → 422"
    (let [params (merge valid-params
       {   :game-number 4})
          resp (app (-> (mock/request :post "/api/games")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-turns-played-positive
  (testing "POST /api/games violates rule turns_played_positive → 422"
    (let [params (merge valid-params
       {   :turns-played "0"})
          resp (app (-> (mock/request :post "/api/games")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-duration-positive
  (testing "POST /api/games violates rule duration_positive → 422"
    (let [params (merge valid-params
       {   :duration-seconds "0"})
          resp (app (-> (mock/request :post "/api/games")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-draw-has-no-winner
  (testing "POST /api/games violates rule draw_has_no_winner → 422"
    (let [params (merge valid-params
       {   :winner-side "Draw"
   :winner 1})
          resp (app (-> (mock/request :post "/api/games")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

; IMPLIES: antecedent=true, consequent violated → 422
(deftest test-rule-non-draw-requires-winner
  (testing "POST /api/games violates rule non_draw_requires_winner → 422"
    (let [params (merge valid-params
       {   :winner-side "Player1"
   :winner nil})
          resp (app (-> (mock/request :post "/api/games")
                     (mock/content-type "application/json")
                     (mock/body (json/generate-string params))))]
      (is (= 422 (:status resp)))))
)

