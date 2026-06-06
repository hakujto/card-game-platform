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
import cards_project.players.model.PlayerTable

enum class TournamentJudgeRoleType {
    HEADJUDGE, JUDGE, SCOREKEEPERJUDGE
}

object TournamentJudgeTable : IntIdTable("tournament_judge") {
    val role = enumerationByName<TournamentJudgeRoleType>("role", 50)
    val tournamentId = reference("tournament_id", TournamentTable)
    val playerId = reference("player_id", PlayerTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class TournamentJudgeRequest(
    val role: TournamentJudgeRoleType,
    val tournamentId: Int,
    val playerId: Int
)

data class TournamentJudgeResponse(
    val id: Int,
    val role: TournamentJudgeRoleType,
    val tournamentId: Int,
    val playerId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toTournamentJudgeResponse() = TournamentJudgeResponse(
    id = this[TournamentJudgeTable.id].value,
    role = this[TournamentJudgeTable.role],
    tournamentId = this[TournamentJudgeTable.tournamentId].value,
    playerId = this[TournamentJudgeTable.playerId].value,
    createdAt = this[TournamentJudgeTable.createdAt].toString(),
    updatedAt = this[TournamentJudgeTable.updatedAt].toString()
)

object TournamentJudgeRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<TournamentJudgeResponse> = transaction {
        TournamentJudgeTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toTournamentJudgeResponse() }
    }

    fun findById(id: Int): TournamentJudgeResponse? = transaction {
        TournamentJudgeTable.selectAll().where { TournamentJudgeTable.id eq id }.singleOrNull()?.toTournamentJudgeResponse()
    }

    fun create(req: TournamentJudgeRequest): TournamentJudgeResponse = transaction {
        val inserted = TournamentJudgeTable.insertAndGetId {
            it[role] = req.role
            it[tournamentId] = EntityID(req.tournamentId, TournamentTable)
            it[playerId] = EntityID(req.playerId, PlayerTable)
        }
        TournamentJudgeTable.selectAll().where { TournamentJudgeTable.id eq inserted }.single().toTournamentJudgeResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        TournamentJudgeTable.deleteWhere { TournamentJudgeTable.id eq id } > 0
    }

}
