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

import cards_project.content.model.DraftParticipantTable
import cards_project.cards.model.CardTable

object DraftPickTable : IntIdTable("draft_pick") {
    val pickNumber = integer("pick_number")
    val packNumber = integer("pack_number")
    val pickedAt = datetime("picked_at")
    val participantId = reference("participant_id", DraftParticipantTable)
    val cardId = reference("card_id", CardTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class DraftPickRequest(
    val pickNumber: Int,
    val packNumber: Int,
    val pickedAt: java.time.LocalDateTime,
    val participantId: Int,
    val cardId: Int
)

data class DraftPickResponse(
    val id: Int,
    val pickNumber: Int,
    val packNumber: Int,
    val pickedAt: java.time.LocalDateTime,
    val participantId: Int,
    val cardId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toDraftPickResponse() = DraftPickResponse(
    id = this[DraftPickTable.id].value,
    pickNumber = this[DraftPickTable.pickNumber],
    packNumber = this[DraftPickTable.packNumber],
    pickedAt = this[DraftPickTable.pickedAt],
    participantId = this[DraftPickTable.participantId].value,
    cardId = this[DraftPickTable.cardId].value,
    createdAt = this[DraftPickTable.createdAt].toString(),
    updatedAt = this[DraftPickTable.updatedAt].toString()
)

object DraftPickRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<DraftPickResponse> = transaction {
        DraftPickTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toDraftPickResponse() }
    }

    fun findById(id: Int): DraftPickResponse? = transaction {
        DraftPickTable.selectAll().where { DraftPickTable.id eq id }.singleOrNull()?.toDraftPickResponse()
    }

}
