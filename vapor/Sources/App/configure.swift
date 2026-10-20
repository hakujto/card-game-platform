import Vapor
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) async throws {
    // Database
    let dbHost = Environment.get("DB_HOST") ?? "localhost"
    let dbPort = Environment.get("DB_PORT").flatMap(Int.init) ?? 5432
    let dbUser = Environment.get("DB_USER") ?? "vapor"
    let dbPass = Environment.get("DB_PASS") ?? "vapor"
    let dbName = Environment.get("DB_NAME") ?? "vapor"
    app.databases.use(.postgres(configuration: .init(
        hostname: dbHost, port: dbPort,
        username: dbUser, password: dbPass,
        database: dbName,
        tls: .prefer(try .init(configuration: .clientDefault))
    )), as: .psql)

    // Migrations
    app.migrations.add(CreateCardSet())
    app.migrations.add(CreateCard())
    app.migrations.add(CreateCardRuling())
    app.migrations.add(CreateCardAbility())
    app.migrations.add(CreatePlayer())
    app.migrations.add(CreateDeck())
    app.migrations.add(CreateDeckCard())
    app.migrations.add(CreateDeckSideboardCard())
    app.migrations.add(CreateDeckTag())
    app.migrations.add(CreateDeckTagAssignment())
    app.migrations.add(CreateSeason())
    app.migrations.add(CreatePlayerSeasonStats())
    app.migrations.add(CreatePlayerCollection())
    app.migrations.add(CreateFriendship())
    app.migrations.add(CreateAchievement())
    app.migrations.add(CreatePlayerAchievement())
    app.migrations.add(CreateCraftingRecipe())
    app.migrations.add(CreateCraftingIngredient())
    app.migrations.add(CreateTournament())
    app.migrations.add(CreateTournamentJudge())
    app.migrations.add(CreateTournamentRegistration())
    app.migrations.add(CreateTournamentRound())
    app.migrations.add(CreateMatch())
    app.migrations.add(CreateGame())
    app.migrations.add(CreateTournamentPrize())
    app.migrations.add(CreateAwardedPrize())
    app.migrations.add(CreateProduct())
    app.migrations.add(CreateCoupon())
    app.migrations.add(CreateOrder())
    app.migrations.add(CreateOrderItem())
    app.migrations.add(CreateTradeListing())
    app.migrations.add(CreateTradeBid())
    app.migrations.add(CreateTradeTransaction())
    app.migrations.add(CreateCardPriceHistory())
    app.migrations.add(CreateTradeDispute())
    app.migrations.add(CreateDraftSession())
    app.migrations.add(CreateDraftParticipant())
    app.migrations.add(CreateDraftPick())
    app.migrations.add(CreateArticle())
    app.migrations.add(CreateArticleTag())
    app.migrations.add(CreateArticleTagAssignment())
    app.migrations.add(CreateArticleComment())
    app.migrations.add(CreateStream())

    // Routes
    try routes(app)
}