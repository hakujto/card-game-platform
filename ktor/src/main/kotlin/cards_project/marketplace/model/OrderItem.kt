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

import cards_project.marketplace.model.OrderTable
import cards_project.marketplace.model.ProductTable

object OrderItemTable : IntIdTable("order_item") {
    val quantity = integer("quantity")
    val priceAtPurchase = decimal("price_at_purchase", 19, 4)
    val foil = bool("foil").default(false)
    val orderId = reference("order_id", OrderTable, onDelete = ReferenceOption.CASCADE)
    val productId = reference("product_id", ProductTable, onDelete = ReferenceOption.RESTRICT)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class OrderItemRequest(
    val quantity: Int,
    val priceAtPurchase: java.math.BigDecimal,
    val foil: Boolean,
    val orderId: Int,
    val productId: Int
)

data class OrderItemResponse(
    val id: Int,
    val quantity: Int,
    val priceAtPurchase: java.math.BigDecimal,
    val foil: Boolean,
    val orderId: Int,
    val productId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toOrderItemResponse() = OrderItemResponse(
    id = this[OrderItemTable.id].value,
    quantity = this[OrderItemTable.quantity],
    priceAtPurchase = this[OrderItemTable.priceAtPurchase],
    foil = this[OrderItemTable.foil],
    orderId = this[OrderItemTable.orderId].value,
    productId = this[OrderItemTable.productId].value,
    createdAt = this[OrderItemTable.createdAt].toString(),
    updatedAt = this[OrderItemTable.updatedAt].toString()
)

object OrderItemRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<OrderItemResponse> = transaction {
        OrderItemTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toOrderItemResponse() }
    }

    fun findById(id: Int): OrderItemResponse? = transaction {
        OrderItemTable.selectAll().where { OrderItemTable.id eq id }.singleOrNull()?.toOrderItemResponse()
    }

    fun create(req: OrderItemRequest): OrderItemResponse = transaction {
        val inserted = OrderItemTable.insertAndGetId {
            it[quantity] = req.quantity
            it[priceAtPurchase] = req.priceAtPurchase
            it[foil] = req.foil
            it[orderId] = EntityID(req.orderId, OrderTable)
            it[productId] = EntityID(req.productId, ProductTable)
        }
        OrderItemTable.selectAll().where { OrderItemTable.id eq inserted }.single().toOrderItemResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        OrderItemTable.deleteWhere { OrderItemTable.id eq id } > 0
    }

}
