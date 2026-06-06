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

import cards_project.marketplace.model.TradeListingTable
import cards_project.players.model.PlayerTable

enum class TradeTransactionStatusType {
    PENDING, COMPLETED, DISPUTED, REFUNDED
}

object TradeTransactionTable : IntIdTable("trade_transaction") {
    val finalPrice = decimal("final_price", 19, 4)
    val platformFee = decimal("platform_fee", 19, 4)
    val status = enumerationByName<TradeTransactionStatusType>("status", 50)
    val completedAt = datetime("completed_at").nullable()
    val listingId = reference("listing_id", TradeListingTable)
    val buyerId = reference("buyer_id", PlayerTable)
    val sellerId = reference("seller_id", PlayerTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class TradeTransactionRequest(
    val finalPrice: java.math.BigDecimal,
    val platformFee: java.math.BigDecimal,
    val status: TradeTransactionStatusType,
    val completedAt: java.time.LocalDateTime? = null,
    val listingId: Int,
    val buyerId: Int,
    val sellerId: Int
)

data class TradeTransactionResponse(
    val id: Int,
    val finalPrice: java.math.BigDecimal,
    val platformFee: java.math.BigDecimal,
    val status: TradeTransactionStatusType,
    val completedAt: java.time.LocalDateTime? = null,
    val listingId: Int,
    val buyerId: Int,
    val sellerId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toTradeTransactionResponse() = TradeTransactionResponse(
    id = this[TradeTransactionTable.id].value,
    finalPrice = this[TradeTransactionTable.finalPrice],
    platformFee = this[TradeTransactionTable.platformFee],
    status = this[TradeTransactionTable.status],
    completedAt = this[TradeTransactionTable.completedAt],
    listingId = this[TradeTransactionTable.listingId].value,
    buyerId = this[TradeTransactionTable.buyerId].value,
    sellerId = this[TradeTransactionTable.sellerId].value,
    createdAt = this[TradeTransactionTable.createdAt].toString(),
    updatedAt = this[TradeTransactionTable.updatedAt].toString()
)

object TradeTransactionRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<TradeTransactionResponse> = transaction {
        TradeTransactionTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toTradeTransactionResponse() }
    }

    fun findById(id: Int): TradeTransactionResponse? = transaction {
        TradeTransactionTable.selectAll().where { TradeTransactionTable.id eq id }.singleOrNull()?.toTradeTransactionResponse()
    }

}
