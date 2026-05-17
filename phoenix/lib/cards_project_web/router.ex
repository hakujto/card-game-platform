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
    end
    resources "/card_sets", CardsProjectWeb.Cards.CardSetController, except: [:new, :edit]
    resources "/card_rulings", CardsProjectWeb.Cards.CardRulingController, except: [:new, :edit]
    resources "/card_abilities", CardsProjectWeb.Cards.CardAbilityController, except: [:new, :edit]
    resources "/decks", CardsProjectWeb.Cards.DeckController, except: [:new, :edit]
    scope "/decks/:id", CardsProjectWeb.Cards, alias: false do
      get "/validate", DeckController, :validate_size
      post "/clone", DeckController, :clone
      post "/publish", DeckController, :publish
      post "/unpublish", DeckController, :unpublish
      post "/certify", DeckController, :certify_tournament_legal
    end
    resources "/deck_cards", CardsProjectWeb.Cards.DeckCardController, except: [:new, :edit]
    resources "/deck_sideboard_cards", CardsProjectWeb.Cards.DeckSideboardCardController, except: [:new, :edit]
    resources "/deck_tags", CardsProjectWeb.Cards.DeckTagController, except: [:new, :edit]
    scope "/deck_tags/:id", CardsProjectWeb.Cards, alias: false do
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
    resources "/player_collections", CardsProjectWeb.Players.PlayerCollectionController, except: [:new, :edit]
    scope "/player_collections/:id", CardsProjectWeb.Players, alias: false do
      get "/value", PlayerCollectionController, :estimated_value
    end
    resources "/friendships", CardsProjectWeb.Players.FriendshipController, except: [:new, :edit]
    scope "/friendships/:id", CardsProjectWeb.Players, alias: false do
      post "/accept", FriendshipController, :accept
      post "/decline", FriendshipController, :decline
      post "/block", FriendshipController, :block
    end
    resources "/achievements", CardsProjectWeb.Players.AchievementController, except: [:new, :edit]
    resources "/player_achievements", CardsProjectWeb.Players.PlayerAchievementController, except: [:new, :edit]
    resources "/crafting_recipes", CardsProjectWeb.Players.CraftingRecipeController, except: [:new, :edit]
    resources "/crafting_ingredients", CardsProjectWeb.Players.CraftingIngredientController, except: [:new, :edit]
    resources "/seasons", CardsProjectWeb.Tournaments.SeasonController, except: [:new, :edit]
    scope "/seasons/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/activate", SeasonController, :activate
      post "/deactivate", SeasonController, :deactivate
      post "/finalize", SeasonController, :finalize_rewards
    end
    resources "/tournaments", CardsProjectWeb.Tournaments.TournamentController, except: [:new, :edit]
    scope "/tournaments/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/start", TournamentController, :start
      post "/cancel", TournamentController, :cancel
      post "/complete", TournamentController, :complete
      post "/rounds", TournamentController, :generate_round
      get "/prizes", TournamentController, :calculate_prize_distribution
    end
    resources "/tournament_judges", CardsProjectWeb.Tournaments.TournamentJudgeController, except: [:new, :edit]
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
    end
    resources "/matches", CardsProjectWeb.Tournaments.MatchController, except: [:new, :edit]
    scope "/matches/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/record", MatchController, :record_result
      get "/winner", MatchController, :determine_winner
      post "/draw", MatchController, :draw
    end
    resources "/games", CardsProjectWeb.Tournaments.GameController, except: [:new, :edit]
    scope "/games/:id", CardsProjectWeb.Tournaments, alias: false do
      post "/winner", GameController, :record_winner
    end
    resources "/tournament_prizes", CardsProjectWeb.Tournaments.TournamentPrizeController, except: [:new, :edit]
    resources "/awarded_prizes", CardsProjectWeb.Tournaments.AwardedPrizeController, except: [:new, :edit]
    resources "/products", CardsProjectWeb.Marketplace.ProductController, except: [:new, :edit]
    scope "/products/:id", CardsProjectWeb.Marketplace, alias: false do
      post "/activate", ProductController, :activate
      post "/deactivate", ProductController, :deactivate
      patch "/discount", ProductController, :apply_discount
      post "/restock", ProductController, :restock
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
    resources "/coupons", CardsProjectWeb.Marketplace.CouponController, except: [:new, :edit]
    scope "/coupons/:id", CardsProjectWeb.Marketplace, alias: false do
      post "/redeem", CouponController, :redeem
      post "/deactivate", CouponController, :deactivate
    end
    resources "/tradelistings", CardsProjectWeb.Marketplace.TradelistingController, except: [:new, :edit]
    scope "/tradelistings/:id", CardsProjectWeb.Marketplace, alias: false do
      post "/close", TradelistingController, :close
      patch "/extend", TradelistingController, :extend
      delete "/cancel", TradelistingController, :cancel
    end
    resources "/trade_bids", CardsProjectWeb.Marketplace.TradeBidController, except: [:new, :edit]
    resources "/trade_transactions", CardsProjectWeb.Marketplace.TradeTransactionController, except: [:new, :edit]
    scope "/trade_transactions/:id", CardsProjectWeb.Marketplace, alias: false do
      post "/complete", TradeTransactionController, :complete
      post "/refund", TradeTransactionController, :refund
      post "/dispute", TradeTransactionController, :open_dispute
    end
    resources "/card_price_histories", CardsProjectWeb.Marketplace.CardPriceHistoryController, except: [:new, :edit]
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
    end
    resources "/draft_participants", CardsProjectWeb.Content.DraftParticipantController, except: [:new, :edit]
    scope "/draft_participants/:id", CardsProjectWeb.Content, alias: false do
      post "/pick", DraftParticipantController, :pick_card
    end
    resources "/draft_picks", CardsProjectWeb.Content.DraftPickController, except: [:new, :edit]
    resources "/articles", CardsProjectWeb.Content.ArticleController, except: [:new, :edit]
    scope "/articles/:id", CardsProjectWeb.Content, alias: false do
      post "/publish", ArticleController, :publish
      post "/archive", ArticleController, :archive
      post "/view", ArticleController, :increment_view
    end
    resources "/article_tags", CardsProjectWeb.Content.ArticleTagController, except: [:new, :edit]
    resources "/article_tag_assignments", CardsProjectWeb.Content.ArticleTagAssignmentController, except: [:new, :edit]
    resources "/article_comments", CardsProjectWeb.Content.ArticleCommentController, except: [:new, :edit]
    scope "/article_comments/:id", CardsProjectWeb.Content, alias: false do
      post "/hide", ArticleCommentController, :hide
      post "/unhide", ArticleCommentController, :unhide
    end
    resources "/streams", CardsProjectWeb.Content.StreamController, except: [:new, :edit]
    scope "/streams/:id", CardsProjectWeb.Content, alias: false do
      post "/live", StreamController, :go_live
      post "/end", StreamController, :end_action
      patch "/viewers", StreamController, :update_viewer_peak
    end
  end
end
