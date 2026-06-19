package cards_project.tournaments.model

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

import cards_project.tournaments.model.TournamentPrizeTable
import cards_project.players.model.*

object AwardedPrizeTable : IntIdTable("awarded_prize") {
    val finalPlacement = integer("final_placement")
    val awardedAt = datetime("awarded_at")
    val claimed = bool("claimed").default(false)
    val claimedAt = datetime("claimed_at").nullable()
    val prizeId = reference("prize_id", TournamentPrizeTable, onDelete = ReferenceOption.RESTRICT)
    val playerId = reference("player_id", PlayerTable, onDelete = ReferenceOption.RESTRICT)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class AwardedPrizeRequest(
    val finalPlacement: Int,
    val awardedAt: java.time.LocalDateTime,
    val claimed: Boolean,
    val claimedAt: java.time.LocalDateTime? = null,
    val prizeId: Int,
    val playerId: Int
)

data class AwardedPrizeResponse(
    val id: Int,
    val finalPlacement: Int,
    val awardedAt: java.time.LocalDateTime,
    val claimed: Boolean,
    val claimedAt: java.time.LocalDateTime? = null,
    val prizeId: Int,
    val playerId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toAwardedPrizeResponse() = AwardedPrizeResponse(
    id = this[AwardedPrizeTable.id].value,
    finalPlacement = this[AwardedPrizeTable.finalPlacement],
    awardedAt = this[AwardedPrizeTable.awardedAt],
    claimed = this[AwardedPrizeTable.claimed],
    claimedAt = this[AwardedPrizeTable.claimedAt],
    prizeId = this[AwardedPrizeTable.prizeId].value,
    playerId = this[AwardedPrizeTable.playerId].value,
    createdAt = this[AwardedPrizeTable.createdAt].toString(),
    updatedAt = this[AwardedPrizeTable.updatedAt].toString()
)

object AwardedPrizeRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<AwardedPrizeResponse> = transaction {
        AwardedPrizeTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toAwardedPrizeResponse() }
    }

    fun findById(id: Int): AwardedPrizeResponse? = transaction {
        AwardedPrizeTable.selectAll().where { AwardedPrizeTable.id eq id }.singleOrNull()?.toAwardedPrizeResponse()
    }

}
