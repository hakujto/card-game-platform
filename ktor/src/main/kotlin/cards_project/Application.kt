package cards_project

import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.routing.*
import cards_project.plugins.*
import cards_project.cards.routes.cardRoutes
import cards_project.cards.routes.cardSetRoutes
import cards_project.cards.routes.cardRulingRoutes
import cards_project.cards.routes.cardAbilityRoutes
import cards_project.cards.routes.deckRoutes
import cards_project.cards.routes.deckCardRoutes
import cards_project.cards.routes.deckSideboardCardRoutes
import cards_project.cards.routes.deckTagRoutes
import cards_project.cards.routes.deckTagAssignmentRoutes
import cards_project.players.routes.playerRoutes
import cards_project.players.routes.playerSeasonStatsRoutes
import cards_project.players.routes.playerCollectionRoutes
import cards_project.players.routes.friendshipRoutes
import cards_project.players.routes.achievementRoutes
import cards_project.players.routes.playerAchievementRoutes
import cards_project.players.routes.craftingRecipeRoutes
import cards_project.players.routes.craftingIngredientRoutes
import cards_project.tournaments.routes.seasonRoutes
import cards_project.tournaments.routes.tournamentRoutes
import cards_project.tournaments.routes.tournamentJudgeRoutes
import cards_project.tournaments.routes.tournamentRegistrationRoutes
import cards_project.tournaments.routes.tournamentRoundRoutes
import cards_project.tournaments.routes.matchRoutes
import cards_project.tournaments.routes.gameRoutes
import cards_project.tournaments.routes.tournamentPrizeRoutes
import cards_project.tournaments.routes.awardedPrizeRoutes
import cards_project.marketplace.routes.productRoutes
import cards_project.marketplace.routes.orderRoutes
import cards_project.marketplace.routes.orderItemRoutes
import cards_project.marketplace.routes.couponRoutes
import cards_project.marketplace.routes.tradeListingRoutes
import cards_project.marketplace.routes.tradeBidRoutes
import cards_project.marketplace.routes.tradeTransactionRoutes
import cards_project.marketplace.routes.cardPriceHistoryRoutes
import cards_project.marketplace.routes.tradeDisputeRoutes
import cards_project.content.routes.draftSessionRoutes
import cards_project.content.routes.draftParticipantRoutes
import cards_project.content.routes.draftPickRoutes
import cards_project.content.routes.articleRoutes
import cards_project.content.routes.articleTagRoutes
import cards_project.content.routes.articleTagAssignmentRoutes
import cards_project.content.routes.articleCommentRoutes
import cards_project.content.routes.streamRoutes

fun main() {
    embeddedServer(Netty, port = System.getenv("PORT")?.toIntOrNull() ?: 8080, host = "0.0.0.0") {
        configureDatabase()
        configureSerialization()
        configureCORS()
        routing {
            cardRoutes()
            cardSetRoutes()
            cardRulingRoutes()
            cardAbilityRoutes()
            deckRoutes()
            deckCardRoutes()
            deckSideboardCardRoutes()
            deckTagRoutes()
            deckTagAssignmentRoutes()
            playerRoutes()
            playerSeasonStatsRoutes()
            playerCollectionRoutes()
            friendshipRoutes()
            achievementRoutes()
            playerAchievementRoutes()
            craftingRecipeRoutes()
            craftingIngredientRoutes()
            seasonRoutes()
            tournamentRoutes()
            tournamentJudgeRoutes()
            tournamentRegistrationRoutes()
            tournamentRoundRoutes()
            matchRoutes()
            gameRoutes()
            tournamentPrizeRoutes()
            awardedPrizeRoutes()
            productRoutes()
            orderRoutes()
            orderItemRoutes()
            couponRoutes()
            tradeListingRoutes()
            tradeBidRoutes()
            tradeTransactionRoutes()
            cardPriceHistoryRoutes()
            tradeDisputeRoutes()
            draftSessionRoutes()
            draftParticipantRoutes()
            draftPickRoutes()
            articleRoutes()
            articleTagRoutes()
            articleTagAssignmentRoutes()
            articleCommentRoutes()
            streamRoutes()
        }
    }.start(wait = true)
}
