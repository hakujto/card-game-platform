package database

import (
	"log"
	"os"

	model_cards "cards_project/internal/model/cards"
	model_players "cards_project/internal/model/players"
	model_tournaments "cards_project/internal/model/tournaments"
	model_marketplace "cards_project/internal/model/marketplace"
	model_content "cards_project/internal/model/content"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Init() {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		dsn = "app.db"
	}
	db, err := gorm.Open(sqlite.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("failed to connect database: %v", err)
	}

	err = db.AutoMigrate(
		&model_cards.Card{},
		&model_cards.CardSet{},
		&model_cards.CardRuling{},
		&model_cards.CardAbility{},
		&model_cards.Deck{},
		&model_cards.DeckCard{},
		&model_cards.DeckSideboardCard{},
		&model_cards.DeckTag{},
		&model_cards.DeckTagAssignment{},
		&model_players.Player{},
		&model_players.PlayerSeasonStats{},
		&model_players.PlayerCollection{},
		&model_players.Friendship{},
		&model_players.Achievement{},
		&model_players.PlayerAchievement{},
		&model_players.CraftingRecipe{},
		&model_players.CraftingIngredient{},
		&model_tournaments.Season{},
		&model_tournaments.Tournament{},
		&model_tournaments.TournamentJudge{},
		&model_tournaments.TournamentRegistration{},
		&model_tournaments.TournamentRound{},
		&model_tournaments.Match{},
		&model_tournaments.Game{},
		&model_tournaments.TournamentPrize{},
		&model_tournaments.AwardedPrize{},
		&model_marketplace.Product{},
		&model_marketplace.Order{},
		&model_marketplace.OrderItem{},
		&model_marketplace.Coupon{},
		&model_marketplace.TradeListing{},
		&model_marketplace.TradeBid{},
		&model_marketplace.TradeTransaction{},
		&model_marketplace.CardPriceHistory{},
		&model_marketplace.TradeDispute{},
		&model_content.DraftSession{},
		&model_content.DraftParticipant{},
		&model_content.DraftPick{},
		&model_content.Article{},
		&model_content.ArticleTag{},
		&model_content.ArticleTagAssignment{},
		&model_content.ArticleComment{},
		&model_content.Stream{},
	)
	if err != nil {
		log.Fatalf("AutoMigrate failed: %v", err)
	}
	DB = db
}
