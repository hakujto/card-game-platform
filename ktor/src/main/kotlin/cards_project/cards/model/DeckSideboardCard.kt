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
import cards_project.cards.model.CardTable

object DeckSideboardCardTable : IntIdTable("deck_sideboard_card") {
    val quantity = integer("quantity").default(1)
    val deckId = reference("deck_id", DeckTable, onDelete = ReferenceOption.CASCADE)
    val cardId = reference("card_id", CardTable, onDelete = ReferenceOption.RESTRICT)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class DeckSideboardCardRequest(
    val quantity: Int,
    val deckId: Int,
    val cardId: Int
)

data class DeckSideboardCardResponse(
    val id: Int,
    val quantity: Int,
    val deckId: Int,
    val cardId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toDeckSideboardCardResponse() = DeckSideboardCardResponse(
    id = this[DeckSideboardCardTable.id].value,
    quantity = this[DeckSideboardCardTable.quantity],
    deckId = this[DeckSideboardCardTable.deckId].value,
    cardId = this[DeckSideboardCardTable.cardId].value,
    createdAt = this[DeckSideboardCardTable.createdAt].toString(),
    updatedAt = this[DeckSideboardCardTable.updatedAt].toString()
)

object DeckSideboardCardRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<DeckSideboardCardResponse> = transaction {
        DeckSideboardCardTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toDeckSideboardCardResponse() }
    }

    fun findById(id: Int): DeckSideboardCardResponse? = transaction {
        DeckSideboardCardTable.selectAll().where { DeckSideboardCardTable.id eq id }.singleOrNull()?.toDeckSideboardCardResponse()
    }

    fun create(req: DeckSideboardCardRequest): DeckSideboardCardResponse = transaction {
        val inserted = DeckSideboardCardTable.insertAndGetId {
            it[quantity] = req.quantity
            it[deckId] = EntityID(req.deckId, DeckTable)
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        DeckSideboardCardTable.selectAll().where { DeckSideboardCardTable.id eq inserted }.single().toDeckSideboardCardResponse()
    }

    fun update(id: Int, req: DeckSideboardCardRequest): DeckSideboardCardResponse? = transaction {
        val updated = DeckSideboardCardTable.update({ DeckSideboardCardTable.id eq id }) {
            it[quantity] = req.quantity
        }
        if (updated == 0) return@transaction null
        DeckSideboardCardTable.selectAll().where { DeckSideboardCardTable.id eq id }.singleOrNull()?.toDeckSideboardCardResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        DeckSideboardCardTable.deleteWhere { DeckSideboardCardTable.id eq id } > 0
    }

}
