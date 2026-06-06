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

import cards_project.tournaments.model.TournamentTable

enum class TournamentPrizePrizeTypeType {
    CURRENCY, CARDS, BOOSTERPACKS, TROPHY, SEASONPOINTS, MIXED
}

object TournamentPrizeTable : IntIdTable("tournament_prize") {
    val placementFrom = integer("placement_from")
    val placementTo = integer("placement_to")
    val prizeType = enumerationByName<TournamentPrizePrizeTypeType>("prize_type", 50)
    val amount = decimal("amount", 19, 4)
    val description = text("description").nullable()
    val packsCount = integer("packs_count").nullable()
    val seasonPoints = integer("season_points")
    val tournamentId = reference("tournament_id", TournamentTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class TournamentPrizeRequest(
    val placementFrom: Int,
    val placementTo: Int,
    val prizeType: TournamentPrizePrizeTypeType,
    val amount: java.math.BigDecimal,
    val description: String? = null,
    val packsCount: Int? = null,
    val seasonPoints: Int,
    val tournamentId: Int
)

data class TournamentPrizeResponse(
    val id: Int,
    val placementFrom: Int,
    val placementTo: Int,
    val prizeType: TournamentPrizePrizeTypeType,
    val amount: java.math.BigDecimal,
    val description: String? = null,
    val packsCount: Int? = null,
    val seasonPoints: Int,
    val tournamentId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toTournamentPrizeResponse() = TournamentPrizeResponse(
    id = this[TournamentPrizeTable.id].value,
    placementFrom = this[TournamentPrizeTable.placementFrom],
    placementTo = this[TournamentPrizeTable.placementTo],
    prizeType = this[TournamentPrizeTable.prizeType],
    amount = this[TournamentPrizeTable.amount],
    description = this[TournamentPrizeTable.description],
    packsCount = this[TournamentPrizeTable.packsCount],
    seasonPoints = this[TournamentPrizeTable.seasonPoints],
    tournamentId = this[TournamentPrizeTable.tournamentId].value,
    createdAt = this[TournamentPrizeTable.createdAt].toString(),
    updatedAt = this[TournamentPrizeTable.updatedAt].toString()
)

object TournamentPrizeRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<TournamentPrizeResponse> = transaction {
        TournamentPrizeTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toTournamentPrizeResponse() }
    }

    fun findById(id: Int): TournamentPrizeResponse? = transaction {
        TournamentPrizeTable.selectAll().where { TournamentPrizeTable.id eq id }.singleOrNull()?.toTournamentPrizeResponse()
    }

    fun create(req: TournamentPrizeRequest): TournamentPrizeResponse = transaction {
        val inserted = TournamentPrizeTable.insertAndGetId {
            it[placementFrom] = req.placementFrom
            it[placementTo] = req.placementTo
            it[prizeType] = req.prizeType
            it[amount] = req.amount
            it[description] = req.description
            it[packsCount] = req.packsCount
            it[seasonPoints] = req.seasonPoints
            it[tournamentId] = EntityID(req.tournamentId, TournamentTable)
        }
        TournamentPrizeTable.selectAll().where { TournamentPrizeTable.id eq inserted }.single().toTournamentPrizeResponse()
    }

    fun update(id: Int, req: TournamentPrizeRequest): TournamentPrizeResponse? = transaction {
        val updated = TournamentPrizeTable.update({ TournamentPrizeTable.id eq id }) {
            it[placementFrom] = req.placementFrom
            it[placementTo] = req.placementTo
            it[prizeType] = req.prizeType
            it[amount] = req.amount
            it[description] = req.description
            it[packsCount] = req.packsCount
            it[seasonPoints] = req.seasonPoints
            it[tournamentId] = EntityID(req.tournamentId, TournamentTable)
        }
        if (updated == 0) return@transaction null
        TournamentPrizeTable.selectAll().where { TournamentPrizeTable.id eq id }.singleOrNull()?.toTournamentPrizeResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        TournamentPrizeTable.deleteWhere { TournamentPrizeTable.id eq id } > 0
    }

}
