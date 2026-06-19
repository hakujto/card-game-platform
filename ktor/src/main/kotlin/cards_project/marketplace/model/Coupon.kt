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

enum class CouponDiscountTypeType {
    PERCENT, FIXED
}

object CouponTable : IntIdTable("coupon") {
    val code = varchar("code", 255).uniqueIndex()
    val discountType = enumerationByName<CouponDiscountTypeType>("discount_type", 50).default(CouponDiscountTypeType.PERCENT)
    val discountValue = decimal("discount_value", 19, 4)
    val minOrderValue = decimal("min_order_value", 19, 4).default(java.math.BigDecimal("0"))
    val maxUses = integer("max_uses").nullable()
    val usesCount = integer("uses_count").default(0)
    val validFrom = datetime("valid_from")
    val validUntil = datetime("valid_until")
    val isActive = bool("is_active").default(true)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class CouponRequest(
    val code: String,
    val discountType: CouponDiscountTypeType,
    val discountValue: java.math.BigDecimal,
    val minOrderValue: java.math.BigDecimal,
    val maxUses: Int? = null,
    val usesCount: Int,
    val validFrom: java.time.LocalDateTime,
    val validUntil: java.time.LocalDateTime,
    val isActive: Boolean
)

data class CouponResponse(
    val id: Int,
    val code: String,
    val discountType: CouponDiscountTypeType,
    val discountValue: java.math.BigDecimal,
    val minOrderValue: java.math.BigDecimal,
    val maxUses: Int? = null,
    val usesCount: Int,
    val validFrom: java.time.LocalDateTime,
    val validUntil: java.time.LocalDateTime,
    val isActive: Boolean,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toCouponResponse() = CouponResponse(
    id = this[CouponTable.id].value,
    code = this[CouponTable.code],
    discountType = this[CouponTable.discountType],
    discountValue = this[CouponTable.discountValue],
    minOrderValue = this[CouponTable.minOrderValue],
    maxUses = this[CouponTable.maxUses],
    usesCount = this[CouponTable.usesCount],
    validFrom = this[CouponTable.validFrom],
    validUntil = this[CouponTable.validUntil],
    isActive = this[CouponTable.isActive],
    createdAt = this[CouponTable.createdAt].toString(),
    updatedAt = this[CouponTable.updatedAt].toString()
)

object CouponRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<CouponResponse> = transaction {
        val query = if (q != null) {
            CouponTable.selectAll().where { (CouponTable.code like "%${q}%") }
        } else {
            CouponTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toCouponResponse() }
    }

    fun findById(id: Int): CouponResponse? = transaction {
        CouponTable.selectAll().where { CouponTable.id eq id }.singleOrNull()?.toCouponResponse()
    }

    fun create(req: CouponRequest): CouponResponse = transaction {
        val inserted = CouponTable.insertAndGetId {
            it[code] = req.code
            it[discountType] = req.discountType
            it[discountValue] = req.discountValue
            it[minOrderValue] = req.minOrderValue
            it[maxUses] = req.maxUses
            it[usesCount] = req.usesCount
            it[validFrom] = req.validFrom
            it[validUntil] = req.validUntil
            it[isActive] = req.isActive
        }
        CouponTable.selectAll().where { CouponTable.id eq inserted }.single().toCouponResponse()
    }

    fun update(id: Int, req: CouponRequest): CouponResponse? = transaction {
        val updated = CouponTable.update({ CouponTable.id eq id }) {
            it[code] = req.code
            it[discountType] = req.discountType
            it[discountValue] = req.discountValue
            it[minOrderValue] = req.minOrderValue
            it[maxUses] = req.maxUses
            it[usesCount] = req.usesCount
            it[validFrom] = req.validFrom
            it[validUntil] = req.validUntil
            it[isActive] = req.isActive
        }
        if (updated == 0) return@transaction null
        CouponTable.selectAll().where { CouponTable.id eq id }.singleOrNull()?.toCouponResponse()
    }

    fun orders(id: Int): List<OrderResponse> = transaction {
        OrderTable.selectAll().where { OrderTable.couponId eq id }.map { it.toOrderResponse() }
    }

}
