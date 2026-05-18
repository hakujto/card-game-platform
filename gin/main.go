package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"

	"cards_project/internal/database"
	handler_cards "cards_project/internal/handler/cards"
	handler_players "cards_project/internal/handler/players"
	handler_tournaments "cards_project/internal/handler/tournaments"
	handler_marketplace "cards_project/internal/handler/marketplace"
	handler_content "cards_project/internal/handler/content"
)

func main() {
	database.Init()

	r := gin.Default()

	// CORS middleware
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET,POST,PUT,PATCH,DELETE,OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type,Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	handler_cards.NewCardHandler(database.DB).RegisterRoutes(r)
	handler_cards.NewCardSetHandler(database.DB).RegisterRoutes(r)
	handler_cards.NewCardRulingHandler(database.DB).RegisterRoutes(r)
	handler_cards.NewCardAbilityHandler(database.DB).RegisterRoutes(r)
	handler_cards.NewDeckHandler(database.DB).RegisterRoutes(r)
	handler_cards.NewDeckCardHandler(database.DB).RegisterRoutes(r)
	handler_cards.NewDeckSideboardCardHandler(database.DB).RegisterRoutes(r)
	handler_cards.NewDeckTagHandler(database.DB).RegisterRoutes(r)
	handler_cards.NewDeckTagAssignmentHandler(database.DB).RegisterRoutes(r)
	handler_players.NewPlayerHandler(database.DB).RegisterRoutes(r)
	handler_players.NewPlayerSeasonStatsHandler(database.DB).RegisterRoutes(r)
	handler_players.NewPlayerCollectionHandler(database.DB).RegisterRoutes(r)
	handler_players.NewFriendshipHandler(database.DB).RegisterRoutes(r)
	handler_players.NewAchievementHandler(database.DB).RegisterRoutes(r)
	handler_players.NewPlayerAchievementHandler(database.DB).RegisterRoutes(r)
	handler_players.NewCraftingRecipeHandler(database.DB).RegisterRoutes(r)
	handler_players.NewCraftingIngredientHandler(database.DB).RegisterRoutes(r)
	handler_tournaments.NewSeasonHandler(database.DB).RegisterRoutes(r)
	handler_tournaments.NewTournamentHandler(database.DB).RegisterRoutes(r)
	handler_tournaments.NewTournamentJudgeHandler(database.DB).RegisterRoutes(r)
	handler_tournaments.NewTournamentRegistrationHandler(database.DB).RegisterRoutes(r)
	handler_tournaments.NewTournamentRoundHandler(database.DB).RegisterRoutes(r)
	handler_tournaments.NewMatchHandler(database.DB).RegisterRoutes(r)
	handler_tournaments.NewGameHandler(database.DB).RegisterRoutes(r)
	handler_tournaments.NewTournamentPrizeHandler(database.DB).RegisterRoutes(r)
	handler_tournaments.NewAwardedPrizeHandler(database.DB).RegisterRoutes(r)
	handler_marketplace.NewProductHandler(database.DB).RegisterRoutes(r)
	handler_marketplace.NewOrderHandler(database.DB).RegisterRoutes(r)
	handler_marketplace.NewOrderItemHandler(database.DB).RegisterRoutes(r)
	handler_marketplace.NewCouponHandler(database.DB).RegisterRoutes(r)
	handler_marketplace.NewTradeListingHandler(database.DB).RegisterRoutes(r)
	handler_marketplace.NewTradeBidHandler(database.DB).RegisterRoutes(r)
	handler_marketplace.NewTradeTransactionHandler(database.DB).RegisterRoutes(r)
	handler_marketplace.NewCardPriceHistoryHandler(database.DB).RegisterRoutes(r)
	handler_marketplace.NewTradeDisputeHandler(database.DB).RegisterRoutes(r)
	handler_content.NewDraftSessionHandler(database.DB).RegisterRoutes(r)
	handler_content.NewDraftParticipantHandler(database.DB).RegisterRoutes(r)
	handler_content.NewDraftPickHandler(database.DB).RegisterRoutes(r)
	handler_content.NewArticleHandler(database.DB).RegisterRoutes(r)
	handler_content.NewArticleTagHandler(database.DB).RegisterRoutes(r)
	handler_content.NewArticleTagAssignmentHandler(database.DB).RegisterRoutes(r)
	handler_content.NewArticleCommentHandler(database.DB).RegisterRoutes(r)
	handler_content.NewStreamHandler(database.DB).RegisterRoutes(r)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Listening on :%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}
