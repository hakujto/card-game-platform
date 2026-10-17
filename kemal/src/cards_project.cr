require "kemal"
require "./db"
require "./models/cards"
require "./routes/cards"
require "./models/players"
require "./routes/players"
require "./models/tournaments"
require "./routes/tournaments"
require "./models/marketplace"
require "./routes/marketplace"
require "./models/content"
require "./routes/content"

# Run migrations
require "./migrations/run"

# Register routes
CardsRoutes.card_routes
CardsRoutes.card_set_routes
CardsRoutes.card_ruling_routes
CardsRoutes.card_ability_routes
CardsRoutes.deck_routes
CardsRoutes.deck_card_routes
CardsRoutes.deck_sideboard_card_routes
CardsRoutes.deck_tag_routes
CardsRoutes.deck_tag_assignment_routes
PlayersRoutes.player_routes
PlayersRoutes.player_season_stats_routes
PlayersRoutes.player_collection_routes
PlayersRoutes.friendship_routes
PlayersRoutes.achievement_routes
PlayersRoutes.player_achievement_routes
PlayersRoutes.crafting_recipe_routes
PlayersRoutes.crafting_ingredient_routes
TournamentsRoutes.season_routes
TournamentsRoutes.tournament_routes
TournamentsRoutes.tournament_judge_routes
TournamentsRoutes.tournament_registration_routes
TournamentsRoutes.tournament_round_routes
TournamentsRoutes.match_routes
TournamentsRoutes.game_routes
TournamentsRoutes.tournament_prize_routes
TournamentsRoutes.awarded_prize_routes
MarketplaceRoutes.product_routes
MarketplaceRoutes.order_routes
MarketplaceRoutes.order_item_routes
MarketplaceRoutes.coupon_routes
MarketplaceRoutes.trade_listing_routes
MarketplaceRoutes.trade_bid_routes
MarketplaceRoutes.trade_transaction_routes
MarketplaceRoutes.card_price_history_routes
MarketplaceRoutes.trade_dispute_routes
ContentRoutes.draft_session_routes
ContentRoutes.draft_participant_routes
ContentRoutes.draft_pick_routes
ContentRoutes.article_routes
ContentRoutes.article_tag_routes
ContentRoutes.article_tag_assignment_routes
ContentRoutes.article_comment_routes
ContentRoutes.stream_routes

# CORS headers
before_all do |env|
  env.response.headers["Access-Control-Allow-Origin"] = "*"
  env.response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS"
  env.response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
end

options "/*" do |env|
  env.response.status_code = 204
end

Kemal.run
