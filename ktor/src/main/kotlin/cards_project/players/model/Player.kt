package cards_project.players.model

import kotlinx.serialization.Serializable
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.like
import org.jetbrains.exposed.sql.javatime.CurrentDateTime
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.javatime.datetime
import org.jetbrains.exposed.sql.transactions.transaction

import cards_project.cards.model.*
import cards_project.tournaments.model.*
import cards_project.marketplace.model.*
import cards_project.content.model.*

enum class PlayerRankType {
    BRONZE, SILVER, GOLD, PLATINUM, DIAMOND, MASTER, GRANDMASTER
}

enum class PlayerPreferredFormatType {
    STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT
}

object PlayerTable : IntIdTable("player") {
    val displayName = varchar("display_name", 255).uniqueIndex()
    val rank = enumerationByName<PlayerRankType>("rank", 50).default(PlayerRankType.BRONZE)
    val rating = integer("rating").default(1000)
    val peakRating = integer("peak_rating").default(1000)
    val bio = text("bio").nullable()
    val countryCode = varchar("country_code", 255).nullable()
    val avatarUrl = text("avatar_url").nullable()
    val preferredFormat = enumerationByName<PlayerPreferredFormatType>("preferred_format", 50).nullable()
    val isVerified = bool("is_verified").default(false)
    val lastActiveAt = datetime("last_active_at").nullable()
    val userId = integer("user_id")
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class PlayerRequest(
    val displayName: String,
    val rank: PlayerRankType,
    val rating: Int,
    val peakRating: Int,
    val bio: String? = null,
    val countryCode: String? = null,
    val avatarUrl: String? = null,
    val preferredFormat: PlayerPreferredFormatType? = null,
    val isVerified: Boolean,
    val lastActiveAt: java.time.LocalDateTime? = null,
    val userId: Int
)

data class PlayerResponse(
    val id: Int,
    val displayName: String,
    val rank: PlayerRankType,
    val rating: Int,
    val peakRating: Int,
    val bio: String? = null,
    val countryCode: String? = null,
    val avatarUrl: String? = null,
    val preferredFormat: PlayerPreferredFormatType? = null,
    val isVerified: Boolean,
    val lastActiveAt: java.time.LocalDateTime? = null,
    val userId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toPlayerResponse() = PlayerResponse(
    id = this[PlayerTable.id].value,
    displayName = this[PlayerTable.displayName],
    rank = this[PlayerTable.rank],
    rating = this[PlayerTable.rating],
    peakRating = this[PlayerTable.peakRating],
    bio = this[PlayerTable.bio],
    countryCode = this[PlayerTable.countryCode],
    avatarUrl = this[PlayerTable.avatarUrl],
    preferredFormat = this[PlayerTable.preferredFormat],
    isVerified = this[PlayerTable.isVerified],
    lastActiveAt = this[PlayerTable.lastActiveAt],
    userId = this[PlayerTable.userId],
    createdAt = this[PlayerTable.createdAt].toString(),
    updatedAt = this[PlayerTable.updatedAt].toString()
)

object PlayerRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<PlayerResponse> = transaction {
        val query = if (q != null) {
            PlayerTable.selectAll().where { (PlayerTable.displayName like "%${q}%") }
        } else {
            PlayerTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toPlayerResponse() }
    }

    fun findById(id: Int): PlayerResponse? = transaction {
        PlayerTable.selectAll().where { PlayerTable.id eq id }.singleOrNull()?.toPlayerResponse()
    }

    fun create(req: PlayerRequest): PlayerResponse = transaction {
        val inserted = PlayerTable.insertAndGetId {
            it[displayName] = req.displayName
            it[rank] = req.rank
            it[rating] = req.rating
            it[peakRating] = req.peakRating
            it[bio] = req.bio
            it[countryCode] = req.countryCode
            it[avatarUrl] = req.avatarUrl
            it[preferredFormat] = req.preferredFormat
            it[isVerified] = req.isVerified
            it[lastActiveAt] = req.lastActiveAt
            it[userId] = req.userId
        }
        PlayerTable.selectAll().where { PlayerTable.id eq inserted }.single().toPlayerResponse()
    }

    fun update(id: Int, req: PlayerRequest): PlayerResponse? = transaction {
        val updated = PlayerTable.update({ PlayerTable.id eq id }) {
            it[displayName] = req.displayName
            it[rank] = req.rank
            it[rating] = req.rating
            it[peakRating] = req.peakRating
            it[bio] = req.bio
            it[countryCode] = req.countryCode
            it[avatarUrl] = req.avatarUrl
            it[preferredFormat] = req.preferredFormat
            it[isVerified] = req.isVerified
            it[lastActiveAt] = req.lastActiveAt
        }
        if (updated == 0) return@transaction null
        PlayerTable.selectAll().where { PlayerTable.id eq id }.singleOrNull()?.toPlayerResponse()
    }

    fun decks(id: Int): List<DeckResponse> = transaction {
        DeckTable.selectAll().where { DeckTable.playerId eq id }.map { it.toDeckResponse() }
    }

    fun seasonStats(id: Int): List<PlayerSeasonStatsResponse> = transaction {
        PlayerSeasonStatsTable.selectAll().where { PlayerSeasonStatsTable.playerId eq id }.map { it.toPlayerSeasonStatsResponse() }
    }

    fun collection(id: Int): List<PlayerCollectionResponse> = transaction {
        PlayerCollectionTable.selectAll().where { PlayerCollectionTable.playerId eq id }.map { it.toPlayerCollectionResponse() }
    }

    fun sentFriendRequests(id: Int): List<FriendshipResponse> = transaction {
        FriendshipTable.selectAll().where { FriendshipTable.requesterId eq id }.map { it.toFriendshipResponse() }
    }

    fun receivedFriendRequests(id: Int): List<FriendshipResponse> = transaction {
        FriendshipTable.selectAll().where { FriendshipTable.receiverId eq id }.map { it.toFriendshipResponse() }
    }

    fun achievementRecords(id: Int): List<PlayerAchievementResponse> = transaction {
        PlayerAchievementTable.selectAll().where { PlayerAchievementTable.playerId eq id }.map { it.toPlayerAchievementResponse() }
    }

    fun organizedTournaments(id: Int): List<TournamentResponse> = transaction {
        TournamentTable.selectAll().where { TournamentTable.organizerId eq id }.map { it.toTournamentResponse() }
    }

    fun judgeRoles(id: Int): List<TournamentJudgeResponse> = transaction {
        TournamentJudgeTable.selectAll().where { TournamentJudgeTable.playerId eq id }.map { it.toTournamentJudgeResponse() }
    }

    fun tournamentRegistrations(id: Int): List<TournamentRegistrationResponse> = transaction {
        TournamentRegistrationTable.selectAll().where { TournamentRegistrationTable.playerId eq id }.map { it.toTournamentRegistrationResponse() }
    }

    fun matchesAsPlayer1(id: Int): List<MatchResponse> = transaction {
        MatchTable.selectAll().where { MatchTable.player1Id eq id }.map { it.toMatchResponse() }
    }

    fun matchesAsPlayer2(id: Int): List<MatchResponse> = transaction {
        MatchTable.selectAll().where { MatchTable.player2Id eq id }.map { it.toMatchResponse() }
    }

    fun wonGames(id: Int): List<GameResponse> = transaction {
        GameTable.selectAll().where { GameTable.winnerId eq id }.map { it.toGameResponse() }
    }

    fun awardedPrizes(id: Int): List<AwardedPrizeResponse> = transaction {
        AwardedPrizeTable.selectAll().where { AwardedPrizeTable.playerId eq id }.map { it.toAwardedPrizeResponse() }
    }

    fun orders(id: Int): List<OrderResponse> = transaction {
        OrderTable.selectAll().where { OrderTable.playerId eq id }.map { it.toOrderResponse() }
    }

    fun tradeListings(id: Int): List<TradeListingResponse> = transaction {
        TradeListingTable.selectAll().where { TradeListingTable.sellerId eq id }.map { it.toTradeListingResponse() }
    }

    fun bids(id: Int): List<TradeBidResponse> = transaction {
        TradeBidTable.selectAll().where { TradeBidTable.bidderId eq id }.map { it.toTradeBidResponse() }
    }

    fun purchases(id: Int): List<TradeTransactionResponse> = transaction {
        TradeTransactionTable.selectAll().where { TradeTransactionTable.buyerId eq id }.map { it.toTradeTransactionResponse() }
    }

    fun sales(id: Int): List<TradeTransactionResponse> = transaction {
        TradeTransactionTable.selectAll().where { TradeTransactionTable.sellerId eq id }.map { it.toTradeTransactionResponse() }
    }

    fun disputesOpened(id: Int): List<TradeDisputeResponse> = transaction {
        TradeDisputeTable.selectAll().where { TradeDisputeTable.openedById eq id }.map { it.toTradeDisputeResponse() }
    }

    fun disputesResolved(id: Int): List<TradeDisputeResponse> = transaction {
        TradeDisputeTable.selectAll().where { TradeDisputeTable.resolvedById eq id }.map { it.toTradeDisputeResponse() }
    }

    fun draftSessions(id: Int): List<DraftParticipantResponse> = transaction {
        DraftParticipantTable.selectAll().where { DraftParticipantTable.playerId eq id }.map { it.toDraftParticipantResponse() }
    }

    fun articles(id: Int): List<ArticleResponse> = transaction {
        ArticleTable.selectAll().where { ArticleTable.authorId eq id }.map { it.toArticleResponse() }
    }

    fun articleComments(id: Int): List<ArticleCommentResponse> = transaction {
        ArticleCommentTable.selectAll().where { ArticleCommentTable.authorId eq id }.map { it.toArticleCommentResponse() }
    }

    fun streams(id: Int): List<StreamResponse> = transaction {
        StreamTable.selectAll().where { StreamTable.streamerId eq id }.map { it.toStreamResponse() }
    }

}
