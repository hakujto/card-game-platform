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

import cards_project.tournaments.model.MatchTable
import cards_project.players.model.PlayerTable

enum class GameWinnerSideType {
    PLAYER1, PLAYER2, DRAW
}

enum class GameEndedByType {
    NORMAL, TIMEOUT, CONCESSION, DRAWOFFER
}

object GameTable : IntIdTable("game") {
    val gameNumber = integer("game_number")
    val winnerSide = enumerationByName<GameWinnerSideType>("winner_side", 50).nullable()
    val turnsPlayed = integer("turns_played").nullable()
    val durationSeconds = integer("duration_seconds").nullable()
    val endedBy = enumerationByName<GameEndedByType>("ended_by", 50).nullable()
    val replayUrl = text("replay_url").nullable()
    val matchId = reference("match_id", MatchTable)
    val winnerId = reference("winner_id", PlayerTable).nullable()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class GameRequest(
    val gameNumber: Int,
    val winnerSide: GameWinnerSideType? = null,
    val turnsPlayed: Int? = null,
    val durationSeconds: Int? = null,
    val endedBy: GameEndedByType? = null,
    val replayUrl: String? = null,
    val matchId: Int,
    val winnerId: Int? = null
)

data class GameResponse(
    val id: Int,
    val gameNumber: Int,
    val winnerSide: GameWinnerSideType? = null,
    val turnsPlayed: Int? = null,
    val durationSeconds: Int? = null,
    val endedBy: GameEndedByType? = null,
    val replayUrl: String? = null,
    val matchId: Int,
    val winnerId: Int?,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toGameResponse() = GameResponse(
    id = this[GameTable.id].value,
    gameNumber = this[GameTable.gameNumber],
    winnerSide = this[GameTable.winnerSide],
    turnsPlayed = this[GameTable.turnsPlayed],
    durationSeconds = this[GameTable.durationSeconds],
    endedBy = this[GameTable.endedBy],
    replayUrl = this[GameTable.replayUrl],
    matchId = this[GameTable.matchId].value,
    winnerId = this[GameTable.winnerId]?.value,
    createdAt = this[GameTable.createdAt].toString(),
    updatedAt = this[GameTable.updatedAt].toString()
)

object GameRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<GameResponse> = transaction {
        GameTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toGameResponse() }
    }

    fun findById(id: Int): GameResponse? = transaction {
        GameTable.selectAll().where { GameTable.id eq id }.singleOrNull()?.toGameResponse()
    }

    fun create(req: GameRequest): GameResponse = transaction {
        val inserted = GameTable.insertAndGetId {
            it[gameNumber] = req.gameNumber
            it[winnerSide] = req.winnerSide
            it[turnsPlayed] = req.turnsPlayed
            it[durationSeconds] = req.durationSeconds
            it[endedBy] = req.endedBy
            it[replayUrl] = req.replayUrl
            it[matchId] = EntityID(req.matchId, MatchTable)
            req.winnerId?.let { v -> it[winnerId] = EntityID(v, PlayerTable) }
        }
        GameTable.selectAll().where { GameTable.id eq inserted }.single().toGameResponse()
    }

}
