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

enum class ProductProductTypeType {
    SINGLECARD, BOOSTERPACK, BUNDLE, PRECONSTRUCTEDDECK, ACCESSORY
}

object ProductTable : IntIdTable("product") {
    val name = varchar("name", 255)
    val productType = enumerationByName<ProductProductTypeType>("product_type", 50).default(ProductProductTypeType.SINGLECARD)
    val price = decimal("price", 19, 4)
    val stock = integer("stock").default(0)
    val active = bool("active").default(true)
    val discountPercent = integer("discount_percent").default(0)
    val description = text("description").nullable()
    val imageUrl = text("image_url").nullable()
    val featured = bool("featured").default(false)
    val cardId = reference("card_id", CardTable, onDelete = ReferenceOption.SET_NULL).nullable().uniqueIndex()
    val cardSetId = reference("card_set_id", CardSetTable, onDelete = ReferenceOption.SET_NULL).nullable()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class ProductRequest(
    val name: String,
    val productType: ProductProductTypeType,
    val price: java.math.BigDecimal,
    val stock: Int,
    val active: Boolean,
    val discountPercent: Int,
    val description: String? = null,
    val imageUrl: String? = null,
    val featured: Boolean,
    val cardId: Int? = null,
    val cardSetId: Int? = null
)

data class ProductResponse(
    val id: Int,
    val name: String,
    val productType: ProductProductTypeType,
    val price: java.math.BigDecimal,
    val stock: Int,
    val active: Boolean,
    val discountPercent: Int,
    val description: String? = null,
    val imageUrl: String? = null,
    val featured: Boolean,
    val cardId: Int?,
    val cardSetId: Int?,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toProductResponse() = ProductResponse(
    id = this[ProductTable.id].value,
    name = this[ProductTable.name],
    productType = this[ProductTable.productType],
    price = this[ProductTable.price],
    stock = this[ProductTable.stock],
    active = this[ProductTable.active],
    discountPercent = this[ProductTable.discountPercent],
    description = this[ProductTable.description],
    imageUrl = this[ProductTable.imageUrl],
    featured = this[ProductTable.featured],
    cardId = this[ProductTable.cardId]?.value,
    cardSetId = this[ProductTable.cardSetId]?.value,
    createdAt = this[ProductTable.createdAt].toString(),
    updatedAt = this[ProductTable.updatedAt].toString()
)

object ProductRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<ProductResponse> = transaction {
        val query = if (q != null) {
            ProductTable.selectAll().where { (ProductTable.name like "%${q}%") or (ProductTable.description like "%${q}%") }
        } else {
            ProductTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toProductResponse() }
    }

    fun findById(id: Int): ProductResponse? = transaction {
        ProductTable.selectAll().where { ProductTable.id eq id }.singleOrNull()?.toProductResponse()
    }

    fun create(req: ProductRequest): ProductResponse = transaction {
        val inserted = ProductTable.insertAndGetId {
            it[name] = req.name
            it[productType] = req.productType
            it[price] = req.price
            it[stock] = req.stock
            it[active] = req.active
            it[discountPercent] = req.discountPercent
            it[description] = req.description
            it[imageUrl] = req.imageUrl
            it[featured] = req.featured
            req.cardId?.let { v -> it[cardId] = EntityID(v, CardTable) }
            req.cardSetId?.let { v -> it[cardSetId] = EntityID(v, CardSetTable) }
        }
        ProductTable.selectAll().where { ProductTable.id eq inserted }.single().toProductResponse()
    }

    fun update(id: Int, req: ProductRequest): ProductResponse? = transaction {
        val updated = ProductTable.update({ ProductTable.id eq id }) {
            it[name] = req.name
            it[productType] = req.productType
            it[price] = req.price
            it[stock] = req.stock
            it[active] = req.active
            it[discountPercent] = req.discountPercent
            it[description] = req.description
            it[imageUrl] = req.imageUrl
            it[featured] = req.featured
            req.cardId?.let { v -> it[cardId] = EntityID(v, CardTable) }
            req.cardSetId?.let { v -> it[cardSetId] = EntityID(v, CardSetTable) }
        }
        if (updated == 0) return@transaction null
        ProductTable.selectAll().where { ProductTable.id eq id }.singleOrNull()?.toProductResponse()
    }

    fun orderItems(id: Int): List<OrderItemResponse> = transaction {
        OrderItemTable.selectAll().where { OrderItemTable.productId eq id }.map { it.toOrderItemResponse() }
    }

}
