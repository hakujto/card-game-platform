(ns cards_project.core
  (:require [compojure.core :refer [routes]]
            [compojure.route :as route]
            [org.httpkit.server :as httpkit]
            [ring.middleware.json :refer [wrap-json-body wrap-json-response]]
            [ring.middleware.cors :refer [wrap-cors]]
            [ring.middleware.params :refer [wrap-params]]
            [ring.middleware.keyword-params :refer [wrap-keyword-params]]
            [cards_project.cards.card-handler :as cards-card]
            [cards_project.cards.card-set-handler :as cards-card-set]
            [cards_project.cards.card-ruling-handler :as cards-card-ruling]
            [cards_project.cards.card-ability-handler :as cards-card-ability]
            [cards_project.cards.deck-handler :as cards-deck]
            [cards_project.cards.deck-card-handler :as cards-deck-card]
            [cards_project.cards.deck-sideboard-card-handler :as cards-deck-sideboard-card]
            [cards_project.cards.deck-tag-handler :as cards-deck-tag]
            [cards_project.cards.deck-tag-assignment-handler :as cards-deck-tag-assignment]
            [cards_project.players.player-handler :as players-player]
            [cards_project.players.player-season-stats-handler :as players-player-season-stats]
            [cards_project.players.player-collection-handler :as players-player-collection]
            [cards_project.players.friendship-handler :as players-friendship]
            [cards_project.players.achievement-handler :as players-achievement]
            [cards_project.players.player-achievement-handler :as players-player-achievement]
            [cards_project.players.crafting-recipe-handler :as players-crafting-recipe]
            [cards_project.players.crafting-ingredient-handler :as players-crafting-ingredient]
            [cards_project.tournaments.season-handler :as tournaments-season]
            [cards_project.tournaments.tournament-handler :as tournaments-tournament]
            [cards_project.tournaments.tournament-judge-handler :as tournaments-tournament-judge]
            [cards_project.tournaments.tournament-registration-handler :as tournaments-tournament-registration]
            [cards_project.tournaments.tournament-round-handler :as tournaments-tournament-round]
            [cards_project.tournaments.match-handler :as tournaments-match]
            [cards_project.tournaments.game-handler :as tournaments-game]
            [cards_project.tournaments.tournament-prize-handler :as tournaments-tournament-prize]
            [cards_project.tournaments.awarded-prize-handler :as tournaments-awarded-prize]
            [cards_project.marketplace.product-handler :as marketplace-product]
            [cards_project.marketplace.order-handler :as marketplace-order]
            [cards_project.marketplace.order-item-handler :as marketplace-order-item]
            [cards_project.marketplace.coupon-handler :as marketplace-coupon]
            [cards_project.marketplace.trade-listing-handler :as marketplace-trade-listing]
            [cards_project.marketplace.trade-bid-handler :as marketplace-trade-bid]
            [cards_project.marketplace.trade-transaction-handler :as marketplace-trade-transaction]
            [cards_project.marketplace.card-price-history-handler :as marketplace-card-price-history]
            [cards_project.marketplace.trade-dispute-handler :as marketplace-trade-dispute]
            [cards_project.content.draft-session-handler :as content-draft-session]
            [cards_project.content.draft-participant-handler :as content-draft-participant]
            [cards_project.content.draft-pick-handler :as content-draft-pick]
            [cards_project.content.article-handler :as content-article]
            [cards_project.content.article-tag-handler :as content-article-tag]
            [cards_project.content.article-tag-assignment-handler :as content-article-tag-assignment]
            [cards_project.content.article-comment-handler :as content-article-comment]
            [cards_project.content.stream-handler :as content-stream])
  (:gen-class))

(def app
  (-> (routes
   cards-card/cards-routes
   cards-card-set/card-sets-routes
   cards-card-ruling/card-rulings-routes
   cards-card-ability/card-abilities-routes
   cards-deck/decks-routes
   cards-deck-card/deck-cards-routes
   cards-deck-sideboard-card/deck-sideboard-cards-routes
   cards-deck-tag/deck-tags-routes
   cards-deck-tag-assignment/deck-tag-assignments-routes
   players-player/players-routes
   players-player-season-stats/player-season-statses-routes
   players-player-collection/player-collections-routes
   players-friendship/friendships-routes
   players-achievement/achievements-routes
   players-player-achievement/player-achievements-routes
   players-crafting-recipe/crafting-recipes-routes
   players-crafting-ingredient/crafting-ingredients-routes
   tournaments-season/seasons-routes
   tournaments-tournament/tournaments-routes
   tournaments-tournament-judge/tournament-judges-routes
   tournaments-tournament-registration/tournament-registrations-routes
   tournaments-tournament-round/tournament-rounds-routes
   tournaments-match/matches-routes
   tournaments-game/games-routes
   tournaments-tournament-prize/tournament-prizes-routes
   tournaments-awarded-prize/awarded-prizes-routes
   marketplace-product/products-routes
   marketplace-order/orders-routes
   marketplace-order-item/order-items-routes
   marketplace-coupon/coupons-routes
   marketplace-trade-listing/trade-listings-routes
   marketplace-trade-bid/trade-bids-routes
   marketplace-trade-transaction/trade-transactions-routes
   marketplace-card-price-history/card-price-histories-routes
   marketplace-trade-dispute/trade-disputes-routes
   content-draft-session/draft-sessions-routes
   content-draft-participant/draft-participants-routes
   content-draft-pick/draft-picks-routes
   content-article/articles-routes
   content-article-tag/article-tags-routes
   content-article-tag-assignment/article-tag-assignments-routes
   content-article-comment/article-comments-routes
   content-stream/streams-routes
       (route/not-found {:error "Not found"}))
      wrap-keyword-params
      wrap-params
      (wrap-json-body {:keywords? true})
      wrap-json-response
      (wrap-cors
        :access-control-allow-origin [#".*"]
        :access-control-allow-methods [:get :post :put :patch :delete :options]
        :access-control-allow-headers ["Content-Type" "Accept"])))

(defn -main [& args]
  (let [port (Integer/parseInt (or (System/getenv "PORT") "3000"))]
    (println (str "Starting server on http://localhost:" port))
    (println (str "API: http://localhost:" port "/api/"))
    (httpkit/run-server app {:port port})
    @(promise)))
