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

object TradeBidTable : IntIdTable("trade_bid") {
    val amount = decimal("amount", 19, 4)
    val placedAt = datetime("placed_at")
    val isWinning = bool("is_winning")
    val listingId = reference("listing_id", TradeListingTable)
    val bidderId = reference("bidder_id", PlayerTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class TradeBidRequest(
    val amount: java.math.BigDecimal,
    val placedAt: java.time.LocalDateTime,
    val isWinning: Boolean,
    val listingId: Int,
    val bidderId: Int
)

data class TradeBidResponse(
    val id: Int,
    val amount: java.math.BigDecimal,
    val placedAt: java.time.LocalDateTime,
    val isWinning: Boolean,
    val listingId: Int,
    val bidderId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toTradeBidResponse() = TradeBidResponse(
    id = this[TradeBidTable.id].value,
    amount = this[TradeBidTable.amount],
    placedAt = this[TradeBidTable.placedAt],
    isWinning = this[TradeBidTable.isWinning],
    listingId = this[TradeBidTable.listingId].value,
    bidderId = this[TradeBidTable.bidderId].value,
    createdAt = this[TradeBidTable.createdAt].toString(),
    updatedAt = this[TradeBidTable.updatedAt].toString()
)

object TradeBidRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<TradeBidResponse> = transaction {
        TradeBidTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toTradeBidResponse() }
    }

    fun findById(id: Int): TradeBidResponse? = transaction {
        TradeBidTable.selectAll().where { TradeBidTable.id eq id }.singleOrNull()?.toTradeBidResponse()
    }

    fun create(req: TradeBidRequest): TradeBidResponse = transaction {
        val inserted = TradeBidTable.insertAndGetId {
            it[amount] = req.amount
            it[placedAt] = req.placedAt
            it[isWinning] = req.isWinning
            it[listingId] = EntityID(req.listingId, TradeListingTable)
            it[bidderId] = EntityID(req.bidderId, PlayerTable)
        }
        TradeBidTable.selectAll().where { TradeBidTable.id eq inserted }.single().toTradeBidResponse()
    }

}
