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

object DeckTagTable : IntIdTable("deck_tag") {
    val name = varchar("name", 255)
    val slug = text("slug").nullable()
    val color = varchar("color", 255).nullable()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class DeckTagRequest(
    val name: String,
    val slug: String? = null,
    val color: String? = null
)

data class DeckTagResponse(
    val id: Int,
    val name: String,
    val slug: String? = null,
    val color: String? = null,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toDeckTagResponse() = DeckTagResponse(
    id = this[DeckTagTable.id].value,
    name = this[DeckTagTable.name],
    slug = this[DeckTagTable.slug],
    color = this[DeckTagTable.color],
    createdAt = this[DeckTagTable.createdAt].toString(),
    updatedAt = this[DeckTagTable.updatedAt].toString()
)

object DeckTagRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<DeckTagResponse> = transaction {
        val query = if (q != null) {
            DeckTagTable.selectAll().where { (DeckTagTable.name like "%${q}%") }
        } else {
            DeckTagTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toDeckTagResponse() }
    }

    fun findById(id: Int): DeckTagResponse? = transaction {
        DeckTagTable.selectAll().where { DeckTagTable.id eq id }.singleOrNull()?.toDeckTagResponse()
    }

    fun create(req: DeckTagRequest): DeckTagResponse = transaction {
        val inserted = DeckTagTable.insertAndGetId {
            it[name] = req.name
            it[slug] = req.slug
            it[color] = req.color
        }
        DeckTagTable.selectAll().where { DeckTagTable.id eq inserted }.single().toDeckTagResponse()
    }

    fun update(id: Int, req: DeckTagRequest): DeckTagResponse? = transaction {
        val updated = DeckTagTable.update({ DeckTagTable.id eq id }) {
            it[name] = req.name
            it[slug] = req.slug
            it[color] = req.color
        }
        if (updated == 0) return@transaction null
        DeckTagTable.selectAll().where { DeckTagTable.id eq id }.singleOrNull()?.toDeckTagResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        DeckTagTable.deleteWhere { DeckTagTable.id eq id } > 0
    }

    fun deckAssignments(id: Int): List<DeckTagAssignmentResponse> = transaction {
        DeckTagAssignmentTable.selectAll().where { DeckTagAssignmentTable.tagId eq id }.map { it.toDeckTagAssignmentResponse() }
    }

}
