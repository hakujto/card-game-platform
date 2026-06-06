package cards_project.cards.model

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

import cards_project.cards.model.DeckTable
import cards_project.cards.model.DeckTagTable

object DeckTagAssignmentTable : IntIdTable("deck_tag_assignment") {
    val deckId = reference("deck_id", DeckTable)
    val tagId = reference("tag_id", DeckTagTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class DeckTagAssignmentRequest(
    val deckId: Int,
    val tagId: Int
)

data class DeckTagAssignmentResponse(
    val id: Int,
    val deckId: Int,
    val tagId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toDeckTagAssignmentResponse() = DeckTagAssignmentResponse(
    id = this[DeckTagAssignmentTable.id].value,
    deckId = this[DeckTagAssignmentTable.deckId].value,
    tagId = this[DeckTagAssignmentTable.tagId].value,
    createdAt = this[DeckTagAssignmentTable.createdAt].toString(),
    updatedAt = this[DeckTagAssignmentTable.updatedAt].toString()
)

object DeckTagAssignmentRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<DeckTagAssignmentResponse> = transaction {
        DeckTagAssignmentTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toDeckTagAssignmentResponse() }
    }

    fun findById(id: Int): DeckTagAssignmentResponse? = transaction {
        DeckTagAssignmentTable.selectAll().where { DeckTagAssignmentTable.id eq id }.singleOrNull()?.toDeckTagAssignmentResponse()
    }

    fun create(req: DeckTagAssignmentRequest): DeckTagAssignmentResponse = transaction {
        val inserted = DeckTagAssignmentTable.insertAndGetId {
            it[deckId] = EntityID(req.deckId, DeckTable)
            it[tagId] = EntityID(req.tagId, DeckTagTable)
        }
        DeckTagAssignmentTable.selectAll().where { DeckTagAssignmentTable.id eq inserted }.single().toDeckTagAssignmentResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        DeckTagAssignmentTable.deleteWhere { DeckTagAssignmentTable.id eq id } > 0
    }

}
