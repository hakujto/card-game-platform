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
import cards_project.cards.model.DeckTable

enum class TournamentRegistrationStatusType {
    REGISTERED, WAITLISTED, WITHDRAWN, DISQUALIFIED
}

object TournamentRegistrationTable : IntIdTable("tournament_registration") {
    val status = enumerationByName<TournamentRegistrationStatusType>("status", 50)
    val seed = integer("seed").nullable()
    val finalStanding = integer("final_standing").nullable()
    val pointsEarned = integer("points_earned")
    val registeredAt = datetime("registered_at")
    val tournamentId = reference("tournament_id", TournamentTable)
    val playerId = reference("player_id", PlayerTable)
    val deckId = reference("deck_id", DeckTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class TournamentRegistrationRequest(
    val status: TournamentRegistrationStatusType,
    val seed: Int? = null,
    val finalStanding: Int? = null,
    val pointsEarned: Int,
    val registeredAt: java.time.LocalDateTime,
    val tournamentId: Int,
    val playerId: Int,
    val deckId: Int
)

data class TournamentRegistrationResponse(
    val id: Int,
    val status: TournamentRegistrationStatusType,
    val seed: Int? = null,
    val finalStanding: Int? = null,
    val pointsEarned: Int,
    val registeredAt: java.time.LocalDateTime,
    val tournamentId: Int,
    val playerId: Int,
    val deckId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toTournamentRegistrationResponse() = TournamentRegistrationResponse(
    id = this[TournamentRegistrationTable.id].value,
    status = this[TournamentRegistrationTable.status],
    seed = this[TournamentRegistrationTable.seed],
    finalStanding = this[TournamentRegistrationTable.finalStanding],
    pointsEarned = this[TournamentRegistrationTable.pointsEarned],
    registeredAt = this[TournamentRegistrationTable.registeredAt],
    tournamentId = this[TournamentRegistrationTable.tournamentId].value,
    playerId = this[TournamentRegistrationTable.playerId].value,
    deckId = this[TournamentRegistrationTable.deckId].value,
    createdAt = this[TournamentRegistrationTable.createdAt].toString(),
    updatedAt = this[TournamentRegistrationTable.updatedAt].toString()
)

object TournamentRegistrationRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<TournamentRegistrationResponse> = transaction {
        TournamentRegistrationTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toTournamentRegistrationResponse() }
    }

    fun findById(id: Int): TournamentRegistrationResponse? = transaction {
        TournamentRegistrationTable.selectAll().where { TournamentRegistrationTable.id eq id }.singleOrNull()?.toTournamentRegistrationResponse()
    }

    fun create(req: TournamentRegistrationRequest): TournamentRegistrationResponse = transaction {
        val inserted = TournamentRegistrationTable.insertAndGetId {
            it[status] = req.status
            it[seed] = req.seed
            it[finalStanding] = req.finalStanding
            it[pointsEarned] = req.pointsEarned
            it[registeredAt] = req.registeredAt
            it[tournamentId] = EntityID(req.tournamentId, TournamentTable)
            it[playerId] = EntityID(req.playerId, PlayerTable)
            it[deckId] = EntityID(req.deckId, DeckTable)
        }
        TournamentRegistrationTable.selectAll().where { TournamentRegistrationTable.id eq inserted }.single().toTournamentRegistrationResponse()
    }

}
