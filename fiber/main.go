package main

import (
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"

	"cards_project/internal/database"
	handler_cards "cards_project/internal/handler/cards"
	handler_players "cards_project/internal/handler/players"
	handler_tournaments "cards_project/internal/handler/tournaments"
	handler_marketplace "cards_project/internal/handler/marketplace"
	handler_content "cards_project/internal/handler/content"
)

func main() {
	database.Init()

	app := fiber.New()

	// CORS middleware
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET,POST,PUT,PATCH,DELETE,OPTIONS",
		AllowHeaders: "Content-Type,Authorization",
	}))

	handler_cards.NewCardHandler(database.DB).RegisterRoutes(app)
	handler_cards.NewCardSetHandler(database.DB).RegisterRoutes(app)
	handler_cards.NewCardRulingHandler(database.DB).RegisterRoutes(app)
	handler_cards.NewCardAbilityHandler(database.DB).RegisterRoutes(app)
	handler_cards.NewDeckHandler(database.DB).RegisterRoutes(app)
	handler_cards.NewDeckCardHandler(database.DB).RegisterRoutes(app)
	handler_cards.NewDeckSideboardCardHandler(database.DB).RegisterRoutes(app)
	handler_cards.NewDeckTagHandler(database.DB).RegisterRoutes(app)
	handler_cards.NewDeckTagAssignmentHandler(database.DB).RegisterRoutes(app)
	handler_players.NewPlayerHandler(database.DB).RegisterRoutes(app)
	handler_players.NewPlayerSeasonStatsHandler(database.DB).RegisterRoutes(app)
	handler_players.NewPlayerCollectionHandler(database.DB).RegisterRoutes(app)
	handler_players.NewFriendshipHandler(database.DB).RegisterRoutes(app)
	handler_players.NewAchievementHandler(database.DB).RegisterRoutes(app)
	handler_players.NewPlayerAchievementHandler(database.DB).RegisterRoutes(app)
	handler_players.NewCraftingRecipeHandler(database.DB).RegisterRoutes(app)
	handler_players.NewCraftingIngredientHandler(database.DB).RegisterRoutes(app)
	handler_tournaments.NewSeasonHandler(database.DB).RegisterRoutes(app)
	handler_tournaments.NewTournamentHandler(database.DB).RegisterRoutes(app)
	handler_tournaments.NewTournamentJudgeHandler(database.DB).RegisterRoutes(app)
	handler_tournaments.NewTournamentRegistrationHandler(database.DB).RegisterRoutes(app)
	handler_tournaments.NewTournamentRoundHandler(database.DB).RegisterRoutes(app)
	handler_tournaments.NewMatchHandler(database.DB).RegisterRoutes(app)
	handler_tournaments.NewGameHandler(database.DB).RegisterRoutes(app)
	handler_tournaments.NewTournamentPrizeHandler(database.DB).RegisterRoutes(app)
	handler_tournaments.NewAwardedPrizeHandler(database.DB).RegisterRoutes(app)
	handler_marketplace.NewProductHandler(database.DB).RegisterRoutes(app)
	handler_marketplace.NewOrderHandler(database.DB).RegisterRoutes(app)
	handler_marketplace.NewOrderItemHandler(database.DB).RegisterRoutes(app)
	handler_marketplace.NewCouponHandler(database.DB).RegisterRoutes(app)
	handler_marketplace.NewTradeListingHandler(database.DB).RegisterRoutes(app)
	handler_marketplace.NewTradeBidHandler(database.DB).RegisterRoutes(app)
	handler_marketplace.NewTradeTransactionHandler(database.DB).RegisterRoutes(app)
	handler_marketplace.NewCardPriceHistoryHandler(database.DB).RegisterRoutes(app)
	handler_marketplace.NewTradeDisputeHandler(database.DB).RegisterRoutes(app)
	handler_content.NewDraftSessionHandler(database.DB).RegisterRoutes(app)
	handler_content.NewDraftParticipantHandler(database.DB).RegisterRoutes(app)
	handler_content.NewDraftPickHandler(database.DB).RegisterRoutes(app)
	handler_content.NewArticleHandler(database.DB).RegisterRoutes(app)
	handler_content.NewArticleTagHandler(database.DB).RegisterRoutes(app)
	handler_content.NewArticleTagAssignmentHandler(database.DB).RegisterRoutes(app)
	handler_content.NewArticleCommentHandler(database.DB).RegisterRoutes(app)
	handler_content.NewStreamHandler(database.DB).RegisterRoutes(app)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Listening on :%s", port)
	if err := app.Listen(":" + port); err != nil {
		log.Fatal(err)
	}
}
