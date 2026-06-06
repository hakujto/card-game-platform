package cards_project.plugins

import io.ktor.server.application.*
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.transactions.transaction
import cards_project.cards.model.CardTable
import cards_project.cards.model.CardSetTable
import cards_project.cards.model.CardRulingTable
import cards_project.cards.model.CardAbilityTable
import cards_project.cards.model.DeckTable
import cards_project.cards.model.DeckCardTable
import cards_project.cards.model.DeckSideboardCardTable
import cards_project.cards.model.DeckTagTable
import cards_project.cards.model.DeckTagAssignmentTable
import cards_project.players.model.PlayerTable
import cards_project.players.model.PlayerSeasonStatsTable
import cards_project.players.model.PlayerCollectionTable
import cards_project.players.model.FriendshipTable
import cards_project.players.model.AchievementTable
import cards_project.players.model.PlayerAchievementTable
import cards_project.players.model.CraftingRecipeTable
import cards_project.players.model.CraftingIngredientTable
import cards_project.tournaments.model.SeasonTable
import cards_project.tournaments.model.TournamentTable
import cards_project.tournaments.model.TournamentJudgeTable
import cards_project.tournaments.model.TournamentRegistrationTable
import cards_project.tournaments.model.TournamentRoundTable
import cards_project.tournaments.model.MatchTable
import cards_project.tournaments.model.GameTable
import cards_project.tournaments.model.TournamentPrizeTable
import cards_project.tournaments.model.AwardedPrizeTable
import cards_project.marketplace.model.ProductTable
import cards_project.marketplace.model.OrderTable
import cards_project.marketplace.model.OrderItemTable
import cards_project.marketplace.model.CouponTable
import cards_project.marketplace.model.TradeListingTable
import cards_project.marketplace.model.TradeBidTable
import cards_project.marketplace.model.TradeTransactionTable
import cards_project.marketplace.model.CardPriceHistoryTable
import cards_project.marketplace.model.TradeDisputeTable
import cards_project.content.model.DraftSessionTable
import cards_project.content.model.DraftParticipantTable
import cards_project.content.model.DraftPickTable
import cards_project.content.model.ArticleTable
import cards_project.content.model.ArticleTagTable
import cards_project.content.model.ArticleTagAssignmentTable
import cards_project.content.model.ArticleCommentTable
import cards_project.content.model.StreamTable

fun Application.configureDatabase() {
    val url = System.getenv("DATABASE_URL") ?: "jdbc:sqlite:app.db"
    Database.connect(url, driver = "org.sqlite.JDBC")
    transaction {
        SchemaUtils.create(
            CardTable,
            CardSetTable,
            CardRulingTable,
            CardAbilityTable,
            DeckTable,
            DeckCardTable,
            DeckSideboardCardTable,
            DeckTagTable,
            DeckTagAssignmentTable,
            PlayerTable,
            PlayerSeasonStatsTable,
            PlayerCollectionTable,
            FriendshipTable,
            AchievementTable,
            PlayerAchievementTable,
            CraftingRecipeTable,
            CraftingIngredientTable,
            SeasonTable,
            TournamentTable,
            TournamentJudgeTable,
            TournamentRegistrationTable,
            TournamentRoundTable,
            MatchTable,
            GameTable,
            TournamentPrizeTable,
            AwardedPrizeTable,
            ProductTable,
            OrderTable,
            OrderItemTable,
            CouponTable,
            TradeListingTable,
            TradeBidTable,
            TradeTransactionTable,
            CardPriceHistoryTable,
            TradeDisputeTable,
            DraftSessionTable,
            DraftParticipantTable,
            DraftPickTable,
            ArticleTable,
            ArticleTagTable,
            ArticleTagAssignmentTable,
            ArticleCommentTable,
            StreamTable
        )
    }
}

fun Application.configureTestDb() {
    val config = com.zaxxer.hikari.HikariConfig().apply {
        jdbcUrl = "jdbc:sqlite::memory:"
        driverClassName = "org.sqlite.JDBC"
        maximumPoolSize = 1
        connectionTestQuery = "SELECT 1"
    }
    Database.connect(com.zaxxer.hikari.HikariDataSource(config))
    transaction {
        SchemaUtils.create(
            CardTable,
            CardSetTable,
            CardRulingTable,
            CardAbilityTable,
            DeckTable,
            DeckCardTable,
            DeckSideboardCardTable,
            DeckTagTable,
            DeckTagAssignmentTable,
            PlayerTable,
            PlayerSeasonStatsTable,
            PlayerCollectionTable,
            FriendshipTable,
            AchievementTable,
            PlayerAchievementTable,
            CraftingRecipeTable,
            CraftingIngredientTable,
            SeasonTable,
            TournamentTable,
            TournamentJudgeTable,
            TournamentRegistrationTable,
            TournamentRoundTable,
            MatchTable,
            GameTable,
            TournamentPrizeTable,
            AwardedPrizeTable,
            ProductTable,
            OrderTable,
            OrderItemTable,
            CouponTable,
            TradeListingTable,
            TradeBidTable,
            TradeTransactionTable,
            CardPriceHistoryTable,
            TradeDisputeTable,
            DraftSessionTable,
            DraftParticipantTable,
            DraftPickTable,
            ArticleTable,
            ArticleTagTable,
            ArticleTagAssignmentTable,
            ArticleCommentTable,
            StreamTable
        )
    }
}
