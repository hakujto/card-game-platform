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

object DeckCardTable : IntIdTable("deck_card") {
    val quantity = integer("quantity")
    val isCommander = bool("is_commander")
    val deckId = reference("deck_id", DeckTable)
    val cardId = reference("card_id", CardTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class DeckCardRequest(
    val quantity: Int,
    val isCommander: Boolean,
    val deckId: Int,
    val cardId: Int
)

data class DeckCardResponse(
    val id: Int,
    val quantity: Int,
    val isCommander: Boolean,
    val deckId: Int,
    val cardId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toDeckCardResponse() = DeckCardResponse(
    id = this[DeckCardTable.id].value,
    quantity = this[DeckCardTable.quantity],
    isCommander = this[DeckCardTable.isCommander],
    deckId = this[DeckCardTable.deckId].value,
    cardId = this[DeckCardTable.cardId].value,
    createdAt = this[DeckCardTable.createdAt].toString(),
    updatedAt = this[DeckCardTable.updatedAt].toString()
)

object DeckCardRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<DeckCardResponse> = transaction {
        DeckCardTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toDeckCardResponse() }
    }

    fun findById(id: Int): DeckCardResponse? = transaction {
        DeckCardTable.selectAll().where { DeckCardTable.id eq id }.singleOrNull()?.toDeckCardResponse()
    }

    fun create(req: DeckCardRequest): DeckCardResponse = transaction {
        val inserted = DeckCardTable.insertAndGetId {
            it[quantity] = req.quantity
            it[isCommander] = req.isCommander
            it[deckId] = EntityID(req.deckId, DeckTable)
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        DeckCardTable.selectAll().where { DeckCardTable.id eq inserted }.single().toDeckCardResponse()
    }

    fun update(id: Int, req: DeckCardRequest): DeckCardResponse? = transaction {
        val updated = DeckCardTable.update({ DeckCardTable.id eq id }) {
            it[quantity] = req.quantity
            it[isCommander] = req.isCommander
            it[deckId] = EntityID(req.deckId, DeckTable)
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        if (updated == 0) return@transaction null
        DeckCardTable.selectAll().where { DeckCardTable.id eq id }.singleOrNull()?.toDeckCardResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        DeckCardTable.deleteWhere { DeckCardTable.id eq id } > 0
    }

}
