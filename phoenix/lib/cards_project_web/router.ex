defmodule CardsProjectWeb.Router do
  use Phoenix.Router, helpers: false

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", alias: false do
    pipe_through :api

    resources "/cards", CardsProjectWeb.Cards.CardController, except: [:new, :edit]
    resources "/card_sets", CardsProjectWeb.Cards.CardSetController, except: [:new, :edit]
    resources "/card_rulings", CardsProjectWeb.Cards.CardRulingController, except: [:new, :edit]
    resources "/card_abilities", CardsProjectWeb.Cards.CardAbilityController, except: [:new, :edit]
    resources "/decks", CardsProjectWeb.Cards.DeckController, except: [:new, :edit]
    resources "/deck_cards", CardsProjectWeb.Cards.DeckCardController, except: [:new, :edit]
    resources "/deck_sideboard_cards", CardsProjectWeb.Cards.DeckSideboardCardController, except: [:new, :edit]
    resources "/deck_tags", CardsProjectWeb.Cards.DeckTagController, except: [:new, :edit]
    resources "/deck_tag_assignments", CardsProjectWeb.Cards.DeckTagAssignmentController, except: [:new, :edit]
    resources "/players", CardsProjectWeb.Players.PlayerController, except: [:new, :edit]
    resources "/player_season_statses", CardsProjectWeb.Players.PlayerSeasonStatsController, except: [:new, :edit]
    resources "/player_collections", CardsProjectWeb.Players.PlayerCollectionController, except: [:new, :edit]
    resources "/friendships", CardsProjectWeb.Players.FriendshipController, except: [:new, :edit]
    resources "/achievements", CardsProjectWeb.Players.AchievementController, except: [:new, :edit]
    resources "/player_achievements", CardsProjectWeb.Players.PlayerAchievementController, except: [:new, :edit]
    resources "/crafting_recipes", CardsProjectWeb.Players.CraftingRecipeController, except: [:new, :edit]
    resources "/crafting_ingredients", CardsProjectWeb.Players.CraftingIngredientController, except: [:new, :edit]
    resources "/seasons", CardsProjectWeb.Tournaments.SeasonController, except: [:new, :edit]
    resources "/tournaments", CardsProjectWeb.Tournaments.TournamentController, except: [:new, :edit]
    resources "/tournament_judges", CardsProjectWeb.Tournaments.TournamentJudgeController, except: [:new, :edit]
    resources "/tournament_registrations", CardsProjectWeb.Tournaments.TournamentRegistrationController, except: [:new, :edit]
    resources "/tournament_rounds", CardsProjectWeb.Tournaments.TournamentRoundController, except: [:new, :edit]
    resources "/matches", CardsProjectWeb.Tournaments.MatchController, except: [:new, :edit]
    resources "/games", CardsProjectWeb.Tournaments.GameController, except: [:new, :edit]
    resources "/tournament_prizes", CardsProjectWeb.Tournaments.TournamentPrizeController, except: [:new, :edit]
    resources "/awarded_prizes", CardsProjectWeb.Tournaments.AwardedPrizeController, except: [:new, :edit]
    resources "/products", CardsProjectWeb.Marketplace.ProductController, except: [:new, :edit]
    resources "/orders", CardsProjectWeb.Marketplace.OrderController, except: [:new, :edit]
    resources "/order_items", CardsProjectWeb.Marketplace.OrderItemController, except: [:new, :edit]
    resources "/coupons", CardsProjectWeb.Marketplace.CouponController, except: [:new, :edit]
    resources "/tradelistings", CardsProjectWeb.Marketplace.TradelistingController, except: [:new, :edit]
    resources "/trade_bids", CardsProjectWeb.Marketplace.TradeBidController, except: [:new, :edit]
    resources "/trade_transactions", CardsProjectWeb.Marketplace.TradeTransactionController, except: [:new, :edit]
    resources "/card_price_histories", CardsProjectWeb.Marketplace.CardPriceHistoryController, except: [:new, :edit]
    resources "/trade_disputes", CardsProjectWeb.Marketplace.TradeDisputeController, except: [:new, :edit]
    resources "/draft_sessions", CardsProjectWeb.Content.DraftSessionController, except: [:new, :edit]
    resources "/draft_participants", CardsProjectWeb.Content.DraftParticipantController, except: [:new, :edit]
    resources "/draft_picks", CardsProjectWeb.Content.DraftPickController, except: [:new, :edit]
    resources "/articles", CardsProjectWeb.Content.ArticleController, except: [:new, :edit]
    resources "/article_tags", CardsProjectWeb.Content.ArticleTagController, except: [:new, :edit]
    resources "/article_tag_assignments", CardsProjectWeb.Content.ArticleTagAssignmentController, except: [:new, :edit]
    resources "/article_comments", CardsProjectWeb.Content.ArticleCommentController, except: [:new, :edit]
    resources "/streams", CardsProjectWeb.Content.StreamController, except: [:new, :edit]
  end
end
