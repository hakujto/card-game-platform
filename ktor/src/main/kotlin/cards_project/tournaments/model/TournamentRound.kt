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

enum class TournamentRoundStatusType {
    PENDING, ACTIVE, COMPLETED
}

object TournamentRoundTable : IntIdTable("tournament_round") {
    val roundNumber = integer("round_number")
    val status = enumerationByName<TournamentRoundStatusType>("status", 50)
    val startedAt = datetime("started_at").nullable()
    val endedAt = datetime("ended_at").nullable()
    val timeLimitMinutes = integer("time_limit_minutes")
    val tournamentId = reference("tournament_id", TournamentTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class TournamentRoundRequest(
    val roundNumber: Int,
    val status: TournamentRoundStatusType,
    val startedAt: java.time.LocalDateTime? = null,
    val endedAt: java.time.LocalDateTime? = null,
    val timeLimitMinutes: Int,
    val tournamentId: Int
)

data class TournamentRoundResponse(
    val id: Int,
    val roundNumber: Int,
    val status: TournamentRoundStatusType,
    val startedAt: java.time.LocalDateTime? = null,
    val endedAt: java.time.LocalDateTime? = null,
    val timeLimitMinutes: Int,
    val tournamentId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toTournamentRoundResponse() = TournamentRoundResponse(
    id = this[TournamentRoundTable.id].value,
    roundNumber = this[TournamentRoundTable.roundNumber],
    status = this[TournamentRoundTable.status],
    startedAt = this[TournamentRoundTable.startedAt],
    endedAt = this[TournamentRoundTable.endedAt],
    timeLimitMinutes = this[TournamentRoundTable.timeLimitMinutes],
    tournamentId = this[TournamentRoundTable.tournamentId].value,
    createdAt = this[TournamentRoundTable.createdAt].toString(),
    updatedAt = this[TournamentRoundTable.updatedAt].toString()
)

object TournamentRoundRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<TournamentRoundResponse> = transaction {
        TournamentRoundTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toTournamentRoundResponse() }
    }

    fun findById(id: Int): TournamentRoundResponse? = transaction {
        TournamentRoundTable.selectAll().where { TournamentRoundTable.id eq id }.singleOrNull()?.toTournamentRoundResponse()
    }

    fun create(req: TournamentRoundRequest): TournamentRoundResponse = transaction {
        val inserted = TournamentRoundTable.insertAndGetId {
            it[roundNumber] = req.roundNumber
            it[status] = req.status
            it[startedAt] = req.startedAt
            it[endedAt] = req.endedAt
            it[timeLimitMinutes] = req.timeLimitMinutes
            it[tournamentId] = EntityID(req.tournamentId, TournamentTable)
        }
        TournamentRoundTable.selectAll().where { TournamentRoundTable.id eq inserted }.single().toTournamentRoundResponse()
    }

}
