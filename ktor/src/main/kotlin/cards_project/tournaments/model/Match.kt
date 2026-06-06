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

import cards_project.tournaments.model.TournamentRoundTable
import cards_project.players.model.PlayerTable

enum class MatchStatusType {
    PENDING, ACTIVE, COMPLETED, BYE, DRAW
}

object MatchTable : IntIdTable("match") {
    val tableNumber = integer("table_number").nullable()
    val status = enumerationByName<MatchStatusType>("status", 50)
    val player1Wins = integer("player1_wins")
    val player2Wins = integer("player2_wins")
    val startedAt = datetime("started_at").nullable()
    val endedAt = datetime("ended_at").nullable()
    val resultNotes = text("result_notes").nullable()
    val roundId = reference("round_id", TournamentRoundTable)
    val player1Id = reference("player1_id", PlayerTable)
    val player2Id = reference("player2_id", PlayerTable).nullable()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class MatchRequest(
    val tableNumber: Int? = null,
    val status: MatchStatusType,
    val player1Wins: Int,
    val player2Wins: Int,
    val startedAt: java.time.LocalDateTime? = null,
    val endedAt: java.time.LocalDateTime? = null,
    val resultNotes: String? = null,
    val roundId: Int,
    val player1Id: Int,
    val player2Id: Int? = null
)

data class MatchResponse(
    val id: Int,
    val tableNumber: Int? = null,
    val status: MatchStatusType,
    val player1Wins: Int,
    val player2Wins: Int,
    val startedAt: java.time.LocalDateTime? = null,
    val endedAt: java.time.LocalDateTime? = null,
    val resultNotes: String? = null,
    val roundId: Int,
    val player1Id: Int,
    val player2Id: Int?,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toMatchResponse() = MatchResponse(
    id = this[MatchTable.id].value,
    tableNumber = this[MatchTable.tableNumber],
    status = this[MatchTable.status],
    player1Wins = this[MatchTable.player1Wins],
    player2Wins = this[MatchTable.player2Wins],
    startedAt = this[MatchTable.startedAt],
    endedAt = this[MatchTable.endedAt],
    resultNotes = this[MatchTable.resultNotes],
    roundId = this[MatchTable.roundId].value,
    player1Id = this[MatchTable.player1Id].value,
    player2Id = this[MatchTable.player2Id]?.value,
    createdAt = this[MatchTable.createdAt].toString(),
    updatedAt = this[MatchTable.updatedAt].toString()
)

object MatchRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<MatchResponse> = transaction {
        MatchTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toMatchResponse() }
    }

    fun findById(id: Int): MatchResponse? = transaction {
        MatchTable.selectAll().where { MatchTable.id eq id }.singleOrNull()?.toMatchResponse()
    }

    fun create(req: MatchRequest): MatchResponse = transaction {
        val inserted = MatchTable.insertAndGetId {
            it[tableNumber] = req.tableNumber
            it[status] = req.status
            it[player1Wins] = req.player1Wins
            it[player2Wins] = req.player2Wins
            it[startedAt] = req.startedAt
            it[endedAt] = req.endedAt
            it[resultNotes] = req.resultNotes
            it[roundId] = EntityID(req.roundId, TournamentRoundTable)
            it[player1Id] = EntityID(req.player1Id, PlayerTable)
            req.player2Id?.let { v -> it[player2Id] = EntityID(v, PlayerTable) }
        }
        MatchTable.selectAll().where { MatchTable.id eq inserted }.single().toMatchResponse()
    }

}
