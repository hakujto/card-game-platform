package cards_project.marketplace.model

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

object CardPriceHistoryTable : IntIdTable("card_price_history") {
    val priceDate = date("price_date")
    val avgPrice = decimal("avg_price", 19, 4)
    val minPrice = decimal("min_price", 19, 4)
    val maxPrice = decimal("max_price", 19, 4)
    val volume = integer("volume")
    val foil = bool("foil").default(false)
    val cardId = reference("card_id", CardTable, onDelete = ReferenceOption.CASCADE)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class CardPriceHistoryRequest(
    val priceDate: java.time.LocalDate,
    val avgPrice: java.math.BigDecimal,
    val minPrice: java.math.BigDecimal,
    val maxPrice: java.math.BigDecimal,
    val volume: Int,
    val foil: Boolean,
    val cardId: Int
)

data class CardPriceHistoryResponse(
    val id: Int,
    val priceDate: java.time.LocalDate,
    val avgPrice: java.math.BigDecimal,
    val minPrice: java.math.BigDecimal,
    val maxPrice: java.math.BigDecimal,
    val volume: Int,
    val foil: Boolean,
    val cardId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toCardPriceHistoryResponse() = CardPriceHistoryResponse(
    id = this[CardPriceHistoryTable.id].value,
    priceDate = this[CardPriceHistoryTable.priceDate],
    avgPrice = this[CardPriceHistoryTable.avgPrice],
    minPrice = this[CardPriceHistoryTable.minPrice],
    maxPrice = this[CardPriceHistoryTable.maxPrice],
    volume = this[CardPriceHistoryTable.volume],
    foil = this[CardPriceHistoryTable.foil],
    cardId = this[CardPriceHistoryTable.cardId].value,
    createdAt = this[CardPriceHistoryTable.createdAt].toString(),
    updatedAt = this[CardPriceHistoryTable.updatedAt].toString()
)

object CardPriceHistoryRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<CardPriceHistoryResponse> = transaction {
        CardPriceHistoryTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toCardPriceHistoryResponse() }
    }

    fun findById(id: Int): CardPriceHistoryResponse? = transaction {
        CardPriceHistoryTable.selectAll().where { CardPriceHistoryTable.id eq id }.singleOrNull()?.toCardPriceHistoryResponse()
    }

}
