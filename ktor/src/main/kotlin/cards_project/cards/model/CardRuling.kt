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

import cards_project.cards.model.CardTable

object CardRulingTable : IntIdTable("card_ruling") {
    val rulingText = text("ruling_text")
    val publishedAt = date("published_at")
    val sourceVal = varchar("source", 255)
    val cardId = reference("card_id", CardTable, onDelete = ReferenceOption.CASCADE)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class CardRulingRequest(
    val rulingText: String,
    val publishedAt: java.time.LocalDate,
    val source: String,
    val cardId: Int
)

data class CardRulingResponse(
    val id: Int,
    val rulingText: String,
    val publishedAt: java.time.LocalDate,
    val source: String,
    val cardId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toCardRulingResponse() = CardRulingResponse(
    id = this[CardRulingTable.id].value,
    rulingText = this[CardRulingTable.rulingText],
    publishedAt = this[CardRulingTable.publishedAt],
    source = this[CardRulingTable.sourceVal],
    cardId = this[CardRulingTable.cardId].value,
    createdAt = this[CardRulingTable.createdAt].toString(),
    updatedAt = this[CardRulingTable.updatedAt].toString()
)

object CardRulingRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<CardRulingResponse> = transaction {
        CardRulingTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toCardRulingResponse() }
    }

    fun findById(id: Int): CardRulingResponse? = transaction {
        CardRulingTable.selectAll().where { CardRulingTable.id eq id }.singleOrNull()?.toCardRulingResponse()
    }

    fun create(req: CardRulingRequest): CardRulingResponse = transaction {
        val inserted = CardRulingTable.insertAndGetId {
            it[rulingText] = req.rulingText
            it[publishedAt] = req.publishedAt
            it[sourceVal] = req.source
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        CardRulingTable.selectAll().where { CardRulingTable.id eq inserted }.single().toCardRulingResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        CardRulingTable.deleteWhere { CardRulingTable.id eq id } > 0
    }

}
