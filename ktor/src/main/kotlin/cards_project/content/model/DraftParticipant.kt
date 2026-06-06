package cards_project.content.model

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

import cards_project.content.model.DraftSessionTable
import cards_project.players.model.PlayerTable

object DraftParticipantTable : IntIdTable("draft_participant") {
    val seatNumber = integer("seat_number")
    val joinedAt = datetime("joined_at")
    val sessionId = reference("session_id", DraftSessionTable)
    val playerId = reference("player_id", PlayerTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class DraftParticipantRequest(
    val seatNumber: Int,
    val joinedAt: java.time.LocalDateTime,
    val sessionId: Int,
    val playerId: Int
)

data class DraftParticipantResponse(
    val id: Int,
    val seatNumber: Int,
    val joinedAt: java.time.LocalDateTime,
    val sessionId: Int,
    val playerId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toDraftParticipantResponse() = DraftParticipantResponse(
    id = this[DraftParticipantTable.id].value,
    seatNumber = this[DraftParticipantTable.seatNumber],
    joinedAt = this[DraftParticipantTable.joinedAt],
    sessionId = this[DraftParticipantTable.sessionId].value,
    playerId = this[DraftParticipantTable.playerId].value,
    createdAt = this[DraftParticipantTable.createdAt].toString(),
    updatedAt = this[DraftParticipantTable.updatedAt].toString()
)

object DraftParticipantRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<DraftParticipantResponse> = transaction {
        DraftParticipantTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toDraftParticipantResponse() }
    }

    fun findById(id: Int): DraftParticipantResponse? = transaction {
        DraftParticipantTable.selectAll().where { DraftParticipantTable.id eq id }.singleOrNull()?.toDraftParticipantResponse()
    }

    fun create(req: DraftParticipantRequest): DraftParticipantResponse = transaction {
        val inserted = DraftParticipantTable.insertAndGetId {
            it[seatNumber] = req.seatNumber
            it[joinedAt] = req.joinedAt
            it[sessionId] = EntityID(req.sessionId, DraftSessionTable)
            it[playerId] = EntityID(req.playerId, PlayerTable)
        }
        DraftParticipantTable.selectAll().where { DraftParticipantTable.id eq inserted }.single().toDraftParticipantResponse()
    }

}
