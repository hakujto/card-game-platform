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

import cards_project.marketplace.model.TradeTransactionTable
import cards_project.players.model.PlayerTable

enum class TradeDisputeStatusType {
    OPEN, UNDERREVIEW, RESOLVED, ESCALATED
}

enum class TradeDisputeReasonType {
    ITEMNOTRECEIVED, ITEMNOTASDESCRIBED, FRAUDSUSPECTED, OTHER
}

object TradeDisputeTable : IntIdTable("trade_dispute") {
    val status = enumerationByName<TradeDisputeStatusType>("status", 50)
    val reason = enumerationByName<TradeDisputeReasonType>("reason", 50)
    val description = text("description")
    val resolution = text("resolution").nullable()
    val openedAt = datetime("opened_at")
    val resolvedAt = datetime("resolved_at").nullable()
    val transactionId = reference("transaction_id", TradeTransactionTable)
    val openedById = reference("opened_by_id", PlayerTable)
    val resolvedById = reference("resolved_by_id", PlayerTable).nullable()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class TradeDisputeRequest(
    val status: TradeDisputeStatusType,
    val reason: TradeDisputeReasonType,
    val description: String,
    val resolution: String? = null,
    val openedAt: java.time.LocalDateTime,
    val resolvedAt: java.time.LocalDateTime? = null,
    val transactionId: Int,
    val openedById: Int,
    val resolvedById: Int? = null
)

data class TradeDisputeResponse(
    val id: Int,
    val status: TradeDisputeStatusType,
    val reason: TradeDisputeReasonType,
    val description: String,
    val resolution: String? = null,
    val openedAt: java.time.LocalDateTime,
    val resolvedAt: java.time.LocalDateTime? = null,
    val transactionId: Int,
    val openedById: Int,
    val resolvedById: Int?,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toTradeDisputeResponse() = TradeDisputeResponse(
    id = this[TradeDisputeTable.id].value,
    status = this[TradeDisputeTable.status],
    reason = this[TradeDisputeTable.reason],
    description = this[TradeDisputeTable.description],
    resolution = this[TradeDisputeTable.resolution],
    openedAt = this[TradeDisputeTable.openedAt],
    resolvedAt = this[TradeDisputeTable.resolvedAt],
    transactionId = this[TradeDisputeTable.transactionId].value,
    openedById = this[TradeDisputeTable.openedById].value,
    resolvedById = this[TradeDisputeTable.resolvedById]?.value,
    createdAt = this[TradeDisputeTable.createdAt].toString(),
    updatedAt = this[TradeDisputeTable.updatedAt].toString()
)

object TradeDisputeRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<TradeDisputeResponse> = transaction {
        TradeDisputeTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toTradeDisputeResponse() }
    }

    fun findById(id: Int): TradeDisputeResponse? = transaction {
        TradeDisputeTable.selectAll().where { TradeDisputeTable.id eq id }.singleOrNull()?.toTradeDisputeResponse()
    }

    fun create(req: TradeDisputeRequest): TradeDisputeResponse = transaction {
        val inserted = TradeDisputeTable.insertAndGetId {
            it[status] = req.status
            it[reason] = req.reason
            it[description] = req.description
            it[resolution] = req.resolution
            it[openedAt] = req.openedAt
            it[resolvedAt] = req.resolvedAt
            it[transactionId] = EntityID(req.transactionId, TradeTransactionTable)
            it[openedById] = EntityID(req.openedById, PlayerTable)
            req.resolvedById?.let { v -> it[resolvedById] = EntityID(v, PlayerTable) }
        }
        TradeDisputeTable.selectAll().where { TradeDisputeTable.id eq inserted }.single().toTradeDisputeResponse()
    }

}
