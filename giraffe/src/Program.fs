module cards_project.Program

open System
open System.IO
open Microsoft.AspNetCore.Builder
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting
open Giraffe
open cards_project.Database
open cards_project.cards.CardHandler
open cards_project.cards.CardSetHandler
open cards_project.cards.CardRulingHandler
open cards_project.cards.CardAbilityHandler
open cards_project.cards.DeckHandler
open cards_project.cards.DeckCardHandler
open cards_project.cards.DeckSideboardCardHandler
open cards_project.cards.DeckTagHandler
open cards_project.cards.DeckTagAssignmentHandler
open cards_project.players.PlayerHandler
open cards_project.players.PlayerSeasonStatsHandler
open cards_project.players.PlayerCollectionHandler
open cards_project.players.FriendshipHandler
open cards_project.players.AchievementHandler
open cards_project.players.PlayerAchievementHandler
open cards_project.players.CraftingRecipeHandler
open cards_project.players.CraftingIngredientHandler
open cards_project.tournaments.SeasonHandler
open cards_project.tournaments.TournamentHandler
open cards_project.tournaments.TournamentJudgeHandler
open cards_project.tournaments.TournamentRegistrationHandler
open cards_project.tournaments.TournamentRoundHandler
open cards_project.tournaments.MatchHandler
open cards_project.tournaments.GameHandler
open cards_project.tournaments.TournamentPrizeHandler
open cards_project.tournaments.AwardedPrizeHandler
open cards_project.marketplace.ProductHandler
open cards_project.marketplace.OrderHandler
open cards_project.marketplace.OrderItemHandler
open cards_project.marketplace.CouponHandler
open cards_project.marketplace.TradeListingHandler
open cards_project.marketplace.TradeBidHandler
open cards_project.marketplace.TradeTransactionHandler
open cards_project.marketplace.CardPriceHistoryHandler
open cards_project.marketplace.TradeDisputeHandler
open cards_project.content.DraftSessionHandler
open cards_project.content.DraftParticipantHandler
open cards_project.content.DraftPickHandler
open cards_project.content.ArticleHandler
open cards_project.content.ArticleTagHandler
open cards_project.content.ArticleTagAssignmentHandler
open cards_project.content.ArticleCommentHandler
open cards_project.content.StreamHandler

let webApp conn =
    choose [
        cardsRoutes conn
        card_setsRoutes conn
        card_rulingsRoutes conn
        card_abilitiesRoutes conn
        decksRoutes conn
        deck_cardsRoutes conn
        deck_sideboard_cardsRoutes conn
        deck_tagsRoutes conn
        deck_tag_assignmentsRoutes conn
        playersRoutes conn
        player_season_statsesRoutes conn
        player_collectionsRoutes conn
        friendshipsRoutes conn
        achievementsRoutes conn
        player_achievementsRoutes conn
        crafting_recipesRoutes conn
        crafting_ingredientsRoutes conn
        seasonsRoutes conn
        tournamentsRoutes conn
        tournament_judgesRoutes conn
        tournament_registrationsRoutes conn
        tournament_roundsRoutes conn
        matchesRoutes conn
        gamesRoutes conn
        tournament_prizesRoutes conn
        awarded_prizesRoutes conn
        productsRoutes conn
        ordersRoutes conn
        order_itemsRoutes conn
        couponsRoutes conn
        trade_listingsRoutes conn
        trade_bidsRoutes conn
        trade_transactionsRoutes conn
        card_price_historiesRoutes conn
        trade_disputesRoutes conn
        draft_sessionsRoutes conn
        draft_participantsRoutes conn
        draft_picksRoutes conn
        articlesRoutes conn
        article_tagsRoutes conn
        article_tag_assignmentsRoutes conn
        article_commentsRoutes conn
        streamsRoutes conn
        setStatusCode 404 >=> json {| error = "Not found" |}
    ]

type Startup() = class end

[<EntryPoint>]
let main _ =
    let dbPath = Environment.GetEnvironmentVariable("DB_PATH") |> Option.ofObj |> Option.defaultValue "app.db"
    let conn = createConnection dbPath

    // Run migrations
    let schemaSql = File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "schema.sql"))
    initializeSchema conn schemaSql

    let builder = WebApplication.CreateBuilder()
    builder.Services.AddGiraffe() |> ignore

    let app = builder.Build()
    app.UseGiraffe(webApp conn)
    app.Run("http://localhost:5050")
    0
