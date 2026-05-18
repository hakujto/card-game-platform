defmodule CardsProjectWeb.Router do
  use Phoenix.Router, helpers: false

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", alias: false do
    pipe_through :api

    resources "/cards", CardsProjectWeb.Cards.CardController, except: [:new, :edit]
    scope "/cards/:id", CardsProjectWeb.Cards, alias: false do
      post "/ban", CardController, :ban
      post "/unban", CardController, :unban
      post "/restrict", CardController, :restrict
      post "/unrestrict", CardController, :unrestrict
      get "/value", CardController, :calculate_value
      post "/rarity-bonus", CardController, :apply_rarity_bonus
      get "/legal", CardController, :is_legal_in_format
    end
    resources "/card_sets", CardsProjectWeb.Cards.CardSetController, except: [:new, :edit]
    scope "/card_sets/:id", CardsProjectWeb.Cards, alias: false do
      get "/standard-legal", CardSetController, :is_legal_in_standard
      get "/legal", CardSetController, :is_legal_in_format
      get "/rarity-count", CardSetController, :card_count_by_rarity
      post "/rotate", CardSetController, :rotate_out
    end
    resources "/card_rulings", CardsProjectWeb.Cards.CardRulingController, except: [:new, :edit]
    scope "/card_rulings/:id", CardsProjectWeb.Cards, alias: false do
      get "/current", CardRulingController, :is_current
      get "/supersedes", CardRulingController, :supersedes_previous
    end
    resources "/card_abilities", CardsProjectWeb.Cards.CardAbilityController, except: [:new, :edit]
    scope "/card_abilities/:id", CardsProjectWeb.Cards, alias: false do
      get "/usable", CardAbilityController, :is_usable_at
      get "/describe", CardAbilityController, :describe
    end
    resources "/decks", CardsProjectWeb.Cards.DeckController, except: [:new, :edit]
    scope "/decks/:id", CardsProjectWeb.Cards, alias: false do
      get "/validate", DeckController, :validate_size
      post "/cards", DeckController, :add_card
      delete "/cards/{card_id}", DeckController, :remove_card
      get "/win-rate", DeckController, :win_rate
      post "/clone", DeckController, :clone
      post "/publish", DeckController, :publish
      post "/unpublish", DeckController, :unpublish
      post "/certify", DeckController, :certify_tournament_legal
    end
    resources "/deck_cards", CardsProjectWeb.Cards.DeckCardController, except: [:new, :edit]
    scope "/deck_cards/:id", CardsProjectWeb.Cards, alias: false do
      patch "/increment", DeckCardController, :increment
      patch "/decrement", DeckCardController, :decrement
    end
    resources "/deck_sideboard_cards", CardsProjectWeb.Cards.DeckSideboardCardController, except: [:new, :edit]
    scope "/deck_sideboard_cards/:id", CardsProjectWeb.Cards, alias: false do
      patch "/increment", DeckSideboardCardController, :increment
      patch "/decrement", DeckSideboardCardController, :decrement
    end
    resources "/deck_tags", CardsProjectWeb.Cards.DeckTagController, except: [:new, :edit]
    scope "/deck_tags/:id", CardsProjectWeb.Cards, alias: false do
      patch "/rename", DeckTagController, :rename
      post "/merge", DeckTagController, :merge_into
    end
    resources "/deck_tag_assignments", CardsProjectWeb.Cards.DeckTagAssignmentController, except: [:new, :edit]
    resources "/players", CardsProjectWeb.Players.PlayerController, except: [:new, :edit]
    scope "/players/:id", CardsProjectWeb.Players, alias: false do
      post "/promote", PlayerController, :promote
      post "/demote", PlayerController, :demote
      post "/win", PlayerController, :record_win
      post "/loss", PlayerController, :record_loss
      get "/win-rate", PlayerController, :win_rate
      post "/verify", PlayerController, :verify
      patch "/rating", PlayerController, :update_rating
    end
    resources "/player_season_statses", CardsProjectWeb.Players.PlayerSeasonStatsController, except: [:new, :edit]
    scope "/player_season_statses/:id", CardsProjectWeb.Players, alias: false do
      get "/win-rate", PlayerSeasonStatsController, :win_rate
      patch "/points", PlayerSeasonStatsController, :add_points
      post "/tournament-win", PlayerSeasonStatsController, :record_tournament_win
    end
    resources "/player_collections", CardsProjectWeb.Players.PlayerCollectionController, except: [:new, :edit]
    scope "/player_collections/:id", CardsProjectWeb.Players, alias: false do
      post "/add", PlayerCollectionController, :add
      post "/remove", PlayerCollectionController, :remove
      get "/value", PlayerCollectionController, :estimated_value
    end
    resources "/friendships", CardsProjectWeb.Players.FriendshipController, except: [:new, :edit]
    scope "/friendships/:id", CardsProjectWeb.Players, alias: false do
      post "/accept", FriendshipController, :accept
      post "/decline", FriendshipController, :decline
      post "/block", FriendshipController, :block
    end
    resources "/achievements", CardsProjectWeb.Players.AchievementController, except: [:new, :edit]
    scope "/achievements/:id", CardsProjectWeb.Players, alias: false do
      get "/point-value", AchievementController, :point_value
      post "/reveal", AchievementController, :reveal
    end
    resources "/player_achievements", CardsProjectWeb.Players.PlayerAchievementController, except: [:new, :edit]
    scope "/player_achievements/:id", CardsProjectWeb.Players, alias: false do
      patch "/progress", PlayerAchievementController, :increment_progress
      post "/complete", PlayerAchievementController, :complete
    end
    resources "/crafting_recipes", CardsProjectWeb.Players.CraftingRecipeController, except: [:new, :edit]
    scope "/crafting_recipes/:id", CardsProjectWeb.Players, alias: false do
      get "/can-craft", CraftingRecipeController, :can_craft
      post "/craft", CraftingRecipeController, :execute_craft
      post "/disable", CraftingRecipeController, :disable
      post "/enable", CraftingRecipeController, :enable
    end
    resources "/crafting_ingredients", CardsProjectWeb.Players.CraftingIngredientController, except: [:new, :edit]
    resources "/seasons", CardsProjectWeb.Tournaments.SeasonController, except: [:new, :edit]
    scope "/seasons/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/activate", SeasonController, :activate
      post "/deactivate", SeasonController, :deactivate
      post "/finalize", SeasonController, :finalize_rewards
      get "/ongoing", SeasonController, :is_ongoing
    end
    resources "/tournaments", CardsProjectWeb.Tournaments.TournamentController, except: [:new, :edit]
    scope "/tournaments/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/start", TournamentController, :start
      post "/cancel", TournamentController, :cancel
      post "/complete", TournamentController, :complete
      post "/rounds", TournamentController, :generate_round
      get "/prizes", TournamentController, :calculate_prize_distribution
      post "/register", TournamentController, :register_player
      get "/full", TournamentController, :is_full
    end
    resources "/tournament_judges", CardsProjectWeb.Tournaments.TournamentJudgeController, except: [:new, :edit]
    scope "/tournament_judges/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/promote", TournamentJudgeController, :promote_to_head
      delete "//api/tournament-judges/{id}", TournamentJudgeController, :remove
    end
    resources "/tournament_registrations", CardsProjectWeb.Tournaments.TournamentRegistrationController, except: [:new, :edit]
    scope "/tournament_registrations/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/withdraw", TournamentRegistrationController, :withdraw
      post "/disqualify", TournamentRegistrationController, :disqualify
      post "/promote", TournamentRegistrationController, :promote_from_waitlist
    end
    resources "/tournament_rounds", CardsProjectWeb.Tournaments.TournamentRoundController, except: [:new, :edit]
    scope "/tournament_rounds/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/start", TournamentRoundController, :start
      post "/complete", TournamentRoundController, :complete
      post "/pairings", TournamentRoundController, :generate_pairings
      get "/time-expired", TournamentRoundController, :is_time_expired
    end
    resources "/matches", CardsProjectWeb.Tournaments.MatchController, except: [:new, :edit]
    scope "/matches/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/record", MatchController, :record_result
      get "/winner", MatchController, :determine_winner
      post "/concede", MatchController, :concede
      post "/draw", MatchController, :draw
    end
    resources "/games", CardsProjectWeb.Tournaments.GameController, except: [:new, :edit]
    scope "/games/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/winner", GameController, :record_winner
      get "/duration", GameController, :duration_minutes
    end
    resources "/tournament_prizes", CardsProjectWeb.Tournaments.TournamentPrizeController, except: [:new, :edit]
    scope "/tournament_prizes/:id", CardsProjectWeb.Tournaments, alias: false do
      get "/applies", TournamentPrizeController, :applies_to_placement
      post "/award", TournamentPrizeController, :award_to_player
    end
    resources "/awarded_prizes", CardsProjectWeb.Tournaments.AwardedPrizeController, except: [:new, :edit]
    scope "/awarded_prizes/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/claim", AwardedPrizeController, :claim
    end
    resources "/products", CardsProjectWeb.Marketplace.ProductController, except: [:new, :edit]
    scope "/products/:id", CardsProjectWeb.Marketplace, alias: false do
      post "/activate", ProductController, :activate
      post "/deactivate", ProductController, :deactivate
      patch "/discount", ProductController, :apply_discount
      post "/restock", ProductController, :restock
      get "/effective-price", ProductController, :effective_price
      get "/in-stock", ProductController, :is_in_stock
    end
    resources "/orders", CardsProjectWeb.Marketplace.OrderController, except: [:new, :edit]
    scope "/orders/:id", CardsProjectWeb.Marketplace, alias: false do
      delete "/cancel", OrderController, :cancel
      post "/pay", OrderController, :pay
      get "/total", OrderController, :calculate_total
      patch "/discount", OrderController, :apply_discount
      post "/refund", OrderController, :refund
    end
    resources "/order_items", CardsProjectWeb.Marketplace.OrderItemController, except: [:new, :edit]
    scope "/order_items/:id", CardsProjectWeb.Marketplace, alias: false do
      get "/total", OrderItemController, :line_total
    end
    resources "/coupons", CardsProjectWeb.Marketplace.CouponController, except: [:new, :edit]
    scope "/coupons/:id", CardsProjectWeb.Marketplace, alias: false do
      get "/valid", CouponController, :is_valid
      get "/applicable", CouponController, :is_applicable_to_order
      post "/redeem", CouponController, :redeem
      post "/deactivate", CouponController, :deactivate
    end
    resources "/trade_listings", CardsProjectWeb.Marketplace.TradeListingController, except: [:new, :edit]
    scope "/trade_listings/:id", CardsProjectWeb.Marketplace, alias: false do
      post "/close", TradeListingController, :close
      patch "/extend", TradeListingController, :extend
      delete "/cancel", TradeListingController, :cancel
      get "/expired", TradeListingController, :is_expired
      post "/finalize", TradeListingController, :finalize_auction
    end
    resources "/trade_bids", CardsProjectWeb.Marketplace.TradeBidController, except: [:new, :edit]
    scope "/trade_bids/:id", CardsProjectWeb.Marketplace, alias: false do
      get "/outbid", TradeBidController, :outbid_by
      delete "//api/bids/{id}", TradeBidController, :retract
    end
    resources "/trade_transactions", CardsProjectWeb.Marketplace.TradeTransactionController, except: [:new, :edit]
    scope "/trade_transactions/:id", CardsProjectWeb.Marketplace, alias: false do
      post "/complete", TradeTransactionController, :complete
      post "/refund", TradeTransactionController, :refund
      post "/dispute", TradeTransactionController, :open_dispute
      get "/seller-net", TradeTransactionController, :seller_net
    end
    resources "/card_price_histories", CardsProjectWeb.Marketplace.CardPriceHistoryController, except: [:new, :edit]
    scope "/card_price_histories/:id", CardsProjectWeb.Marketplace, alias: false do
      get "/change", CardPriceHistoryController, :price_change_percent
      get "/spike", CardPriceHistoryController, :is_price_spike
    end
    resources "/trade_disputes", CardsProjectWeb.Marketplace.TradeDisputeController, except: [:new, :edit]
    scope "/trade_disputes/:id", CardsProjectWeb.Marketplace, alias: false do
      post "/escalate", TradeDisputeController, :escalate
      post "/resolve", TradeDisputeController, :resolve
      post "/review", TradeDisputeController, :review
    end
    resources "/draft_sessions", CardsProjectWeb.Content.DraftSessionController, except: [:new, :edit]
    scope "/draft_sessions/:id", CardsProjectWeb.Content, alias: false do
      post "/start", DraftSessionController, :start
      post "/abandon", DraftSessionController, :abandon
      post "/complete", DraftSessionController, :complete
      get "/full", DraftSessionController, :is_full
    end
    resources "/draft_participants", CardsProjectWeb.Content.DraftParticipantController, except: [:new, :edit]
    scope "/draft_participants/:id", CardsProjectWeb.Content, alias: false do
      post "/pick", DraftParticipantController, :pick_card
      get "/card-count", DraftParticipantController, :drafted_card_count
    end
    resources "/draft_picks", CardsProjectWeb.Content.DraftPickController, except: [:new, :edit]
    scope "/draft_picks/:id", CardsProjectWeb.Content, alias: false do
      get "/first-pick", DraftPickController, :is_first_pick
    end
    resources "/articles", CardsProjectWeb.Content.ArticleController, except: [:new, :edit]
    scope "/articles/:id", CardsProjectWeb.Content, alias: false do
      post "/publish", ArticleController, :publish
      post "/archive", ArticleController, :archive
      post "/view", ArticleController, :increment_view
      get "/reading-time", ArticleController, :reading_time_minutes
    end
    resources "/article_tags", CardsProjectWeb.Content.ArticleTagController, except: [:new, :edit]
    scope "/article_tags/:id", CardsProjectWeb.Content, alias: false do
      patch "/rename", ArticleTagController, :rename
      get "/article-count", ArticleTagController, :article_count
    end
    resources "/article_tag_assignments", CardsProjectWeb.Content.ArticleTagAssignmentController, except: [:new, :edit]
    resources "/article_comments", CardsProjectWeb.Content.ArticleCommentController, except: [:new, :edit]
    scope "/article_comments/:id", CardsProjectWeb.Content, alias: false do
      post "/hide", ArticleCommentController, :hide
      post "/unhide", ArticleCommentController, :unhide
      get "/is-reply", ArticleCommentController, :is_reply
    end
    resources "/streams", CardsProjectWeb.Content.StreamController, except: [:new, :edit]
    scope "/streams/:id", CardsProjectWeb.Content, alias: false do
      post "/live", StreamController, :go_live
      post "/end", StreamController, :end_action
      patch "/viewers", StreamController, :update_viewer_peak
      get "/duration", StreamController, :duration_minutes
    end
  end
end
