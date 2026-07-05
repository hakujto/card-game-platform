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

import cards_project.cards.model.*

enum class DraftSessionStatusType {
    WAITINGFORPLAYERS, DRAFTING, COMPLETED, ABANDONED
}

enum class DraftSessionDraftTypeType {
    BOOSTER, CUBE, ROCHESTER
}

object DraftSessionTable : IntIdTable("draft_session") {
    val status = enumerationByName<DraftSessionStatusType>("status", 50).default(DraftSessionStatusType.WAITINGFORPLAYERS)
    val draftType = enumerationByName<DraftSessionDraftTypeType>("draft_type", 50).default(DraftSessionDraftTypeType.BOOSTER)
    val packContents = text("pack_contents").nullable()
    val seats = integer("seats").default(8)
    val timePerPickSeconds = integer("time_per_pick_seconds").default(30)
    val completedAt = datetime("completed_at").nullable()
    val cardSetId = reference("card_set_id", CardSetTable, onDelete = ReferenceOption.RESTRICT)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class DraftSessionRequest(
    val status: DraftSessionStatusType,
    val draftType: DraftSessionDraftTypeType,
    val packContents: String? = null,
    val seats: Int,
    val timePerPickSeconds: Int,
    val completedAt: java.time.LocalDateTime? = null,
    val cardSetId: Int
)

data class DraftSessionResponse(
    val id: Int,
    val status: DraftSessionStatusType,
    val draftType: DraftSessionDraftTypeType,
    val packContents: String? = null,
    val seats: Int,
    val timePerPickSeconds: Int,
    val completedAt: java.time.LocalDateTime? = null,
    val cardSetId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toDraftSessionResponse() = DraftSessionResponse(
    id = this[DraftSessionTable.id].value,
    status = this[DraftSessionTable.status],
    draftType = this[DraftSessionTable.draftType],
    packContents = this[DraftSessionTable.packContents],
    seats = this[DraftSessionTable.seats],
    timePerPickSeconds = this[DraftSessionTable.timePerPickSeconds],
    completedAt = this[DraftSessionTable.completedAt],
    cardSetId = this[DraftSessionTable.cardSetId].value,
    createdAt = this[DraftSessionTable.createdAt].toString(),
    updatedAt = this[DraftSessionTable.updatedAt].toString()
)

object DraftSessionRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<DraftSessionResponse> = transaction {
        DraftSessionTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toDraftSessionResponse() }
    }

    fun findById(id: Int): DraftSessionResponse? = transaction {
        DraftSessionTable.selectAll().where { DraftSessionTable.id eq id }.singleOrNull()?.toDraftSessionResponse()
    }

    fun create(req: DraftSessionRequest): DraftSessionResponse = transaction {
        val inserted = DraftSessionTable.insertAndGetId {
            it[status] = req.status
            it[draftType] = req.draftType
            it[packContents] = req.packContents
            it[seats] = req.seats
            it[timePerPickSeconds] = req.timePerPickSeconds
            it[completedAt] = req.completedAt
            it[cardSetId] = EntityID(req.cardSetId, CardSetTable)
        }
        DraftSessionTable.selectAll().where { DraftSessionTable.id eq inserted }.single().toDraftSessionResponse()
    }

    fun updateStatus(id: Int, newStatus: String): DraftSessionResponse? = transaction {
        val updated = DraftSessionTable.update({ DraftSessionTable.id eq id }) {
            it[status] = DraftSessionStatusType.valueOf(newStatus)
        }
        if (updated == 0) return@transaction null
        DraftSessionTable.selectAll().where { DraftSessionTable.id eq id }.singleOrNull()?.toDraftSessionResponse()
    }

    fun participants(id: Int): List<DraftParticipantResponse> = transaction {
        DraftParticipantTable.selectAll().where { DraftParticipantTable.sessionId eq id }.map { it.toDraftParticipantResponse() }
    }

}
