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
import cards_project.marketplace.model.CouponTable

enum class OrderStatusType {
    PENDING, PAID, PROCESSING, SHIPPED, COMPLETED, CANCELLED, REFUNDED
}

enum class OrderPaymentMethodType {
    CARD, PAYPAL, CRYPTO, PLATFORMCREDITS
}

object OrderTable : IntIdTable("order") {
    val status = enumerationByName<OrderStatusType>("status", 50)
    val total = decimal("total", 19, 4)
    val discountApplied = decimal("discount_applied", 19, 4)
    val currency = varchar("currency", 255)
    val paymentMethod = enumerationByName<OrderPaymentMethodType>("payment_method", 50).nullable()
    val paymentReference = varchar("payment_reference", 255).nullable()
    val shippingAddress = text("shipping_address").nullable()
    val trackingNumber = varchar("tracking_number", 255).nullable()
    val paidAt = datetime("paid_at").nullable()
    val shippedAt = datetime("shipped_at").nullable()
    val playerId = reference("player_id", PlayerTable)
    val couponId = reference("coupon_id", CouponTable).nullable()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class OrderRequest(
    val status: OrderStatusType,
    val total: java.math.BigDecimal,
    val discountApplied: java.math.BigDecimal,
    val currency: String,
    val paymentMethod: OrderPaymentMethodType? = null,
    val paymentReference: String? = null,
    val shippingAddress: String? = null,
    val trackingNumber: String? = null,
    val paidAt: java.time.LocalDateTime? = null,
    val shippedAt: java.time.LocalDateTime? = null,
    val playerId: Int,
    val couponId: Int? = null
)

data class OrderResponse(
    val id: Int,
    val status: OrderStatusType,
    val total: java.math.BigDecimal,
    val discountApplied: java.math.BigDecimal,
    val currency: String,
    val paymentMethod: OrderPaymentMethodType? = null,
    val paymentReference: String? = null,
    val shippingAddress: String? = null,
    val trackingNumber: String? = null,
    val paidAt: java.time.LocalDateTime? = null,
    val shippedAt: java.time.LocalDateTime? = null,
    val playerId: Int,
    val couponId: Int?,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toOrderResponse() = OrderResponse(
    id = this[OrderTable.id].value,
    status = this[OrderTable.status],
    total = this[OrderTable.total],
    discountApplied = this[OrderTable.discountApplied],
    currency = this[OrderTable.currency],
    paymentMethod = this[OrderTable.paymentMethod],
    paymentReference = this[OrderTable.paymentReference],
    shippingAddress = this[OrderTable.shippingAddress],
    trackingNumber = this[OrderTable.trackingNumber],
    paidAt = this[OrderTable.paidAt],
    shippedAt = this[OrderTable.shippedAt],
    playerId = this[OrderTable.playerId].value,
    couponId = this[OrderTable.couponId]?.value,
    createdAt = this[OrderTable.createdAt].toString(),
    updatedAt = this[OrderTable.updatedAt].toString()
)

object OrderRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<OrderResponse> = transaction {
        OrderTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toOrderResponse() }
    }

    fun findById(id: Int): OrderResponse? = transaction {
        OrderTable.selectAll().where { OrderTable.id eq id }.singleOrNull()?.toOrderResponse()
    }

    fun create(req: OrderRequest): OrderResponse = transaction {
        val inserted = OrderTable.insertAndGetId {
            it[status] = req.status
            it[total] = req.total
            it[discountApplied] = req.discountApplied
            it[currency] = req.currency
            it[paymentMethod] = req.paymentMethod
            it[paymentReference] = req.paymentReference
            it[shippingAddress] = req.shippingAddress
            it[trackingNumber] = req.trackingNumber
            it[paidAt] = req.paidAt
            it[shippedAt] = req.shippedAt
            it[playerId] = EntityID(req.playerId, PlayerTable)
            req.couponId?.let { v -> it[couponId] = EntityID(v, CouponTable) }
        }
        OrderTable.selectAll().where { OrderTable.id eq inserted }.single().toOrderResponse()
    }

}
