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

import cards_project.players.model.PlayerTable
import cards_project.cards.model.CardTable

enum class TradeListingStatusType {
    ACTIVE, SOLD, EXPIRED, CANCELLED, PENDING
}

enum class TradeListingListingTypeType {
    FIXEDPRICE, AUCTION, TRADEOFFER
}

enum class TradeListingConditionType {
    MINT, NEARMINT, EXCELLENT, GOOD, PLAYED
}

object TradeListingTable : IntIdTable("trade_listing") {
    val status = enumerationByName<TradeListingStatusType>("status", 50)
    val listingType = enumerationByName<TradeListingListingTypeType>("listing_type", 50)
    val askingPrice = decimal("asking_price", 19, 4).nullable()
    val auctionStartPrice = decimal("auction_start_price", 19, 4).nullable()
    val auctionCurrentBid = decimal("auction_current_bid", 19, 4).nullable()
    val auctionEndTime = datetime("auction_end_time").nullable()
    val foil = bool("foil")
    val condition = enumerationByName<TradeListingConditionType>("condition", 50)
    val quantity = integer("quantity")
    val description = text("description").nullable()
    val expiresAt = datetime("expires_at").nullable()
    val sellerId = reference("seller_id", PlayerTable)
    val cardId = reference("card_id", CardTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class TradeListingRequest(
    val status: TradeListingStatusType,
    val listingType: TradeListingListingTypeType,
    val askingPrice: java.math.BigDecimal? = null,
    val auctionStartPrice: java.math.BigDecimal? = null,
    val auctionCurrentBid: java.math.BigDecimal? = null,
    val auctionEndTime: java.time.LocalDateTime? = null,
    val foil: Boolean,
    val condition: TradeListingConditionType,
    val quantity: Int,
    val description: String? = null,
    val expiresAt: java.time.LocalDateTime? = null,
    val sellerId: Int,
    val cardId: Int
)

data class TradeListingResponse(
    val id: Int,
    val status: TradeListingStatusType,
    val listingType: TradeListingListingTypeType,
    val askingPrice: java.math.BigDecimal? = null,
    val auctionStartPrice: java.math.BigDecimal? = null,
    val auctionCurrentBid: java.math.BigDecimal? = null,
    val auctionEndTime: java.time.LocalDateTime? = null,
    val foil: Boolean,
    val condition: TradeListingConditionType,
    val quantity: Int,
    val description: String? = null,
    val expiresAt: java.time.LocalDateTime? = null,
    val sellerId: Int,
    val cardId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toTradeListingResponse() = TradeListingResponse(
    id = this[TradeListingTable.id].value,
    status = this[TradeListingTable.status],
    listingType = this[TradeListingTable.listingType],
    askingPrice = this[TradeListingTable.askingPrice],
    auctionStartPrice = this[TradeListingTable.auctionStartPrice],
    auctionCurrentBid = this[TradeListingTable.auctionCurrentBid],
    auctionEndTime = this[TradeListingTable.auctionEndTime],
    foil = this[TradeListingTable.foil],
    condition = this[TradeListingTable.condition],
    quantity = this[TradeListingTable.quantity],
    description = this[TradeListingTable.description],
    expiresAt = this[TradeListingTable.expiresAt],
    sellerId = this[TradeListingTable.sellerId].value,
    cardId = this[TradeListingTable.cardId].value,
    createdAt = this[TradeListingTable.createdAt].toString(),
    updatedAt = this[TradeListingTable.updatedAt].toString()
)

object TradeListingRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<TradeListingResponse> = transaction {
        val query = if (q != null) {
            TradeListingTable.selectAll().where { (TradeListingTable.description like "%${q}%") }
        } else {
            TradeListingTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toTradeListingResponse() }
    }

    fun findById(id: Int): TradeListingResponse? = transaction {
        TradeListingTable.selectAll().where { TradeListingTable.id eq id }.singleOrNull()?.toTradeListingResponse()
    }

    fun create(req: TradeListingRequest): TradeListingResponse = transaction {
        val inserted = TradeListingTable.insertAndGetId {
            it[status] = req.status
            it[listingType] = req.listingType
            it[askingPrice] = req.askingPrice
            it[auctionStartPrice] = req.auctionStartPrice
            it[auctionCurrentBid] = req.auctionCurrentBid
            it[auctionEndTime] = req.auctionEndTime
            it[foil] = req.foil
            it[condition] = req.condition
            it[quantity] = req.quantity
            it[description] = req.description
            it[expiresAt] = req.expiresAt
            it[sellerId] = EntityID(req.sellerId, PlayerTable)
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        TradeListingTable.selectAll().where { TradeListingTable.id eq inserted }.single().toTradeListingResponse()
    }

    fun update(id: Int, req: TradeListingRequest): TradeListingResponse? = transaction {
        val updated = TradeListingTable.update({ TradeListingTable.id eq id }) {
            it[status] = req.status
            it[listingType] = req.listingType
            it[askingPrice] = req.askingPrice
            it[auctionStartPrice] = req.auctionStartPrice
            it[auctionCurrentBid] = req.auctionCurrentBid
            it[auctionEndTime] = req.auctionEndTime
            it[foil] = req.foil
            it[condition] = req.condition
            it[quantity] = req.quantity
            it[description] = req.description
            it[expiresAt] = req.expiresAt
            it[sellerId] = EntityID(req.sellerId, PlayerTable)
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        if (updated == 0) return@transaction null
        TradeListingTable.selectAll().where { TradeListingTable.id eq id }.singleOrNull()?.toTradeListingResponse()
    }

}
