package cards_project.players.model

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

enum class PlayerCollectionConditionType {
    MINT, NEARMINT, EXCELLENT, GOOD, PLAYED
}

enum class PlayerCollectionAcquiredViaType {
    PURCHASE, TRADE, TOURNAMENTREWARD, PACK, CRAFT
}

object PlayerCollectionTable : IntIdTable("player_collection") {
    val quantity = integer("quantity")
    val foil = bool("foil")
    val condition = enumerationByName<PlayerCollectionConditionType>("condition", 50)
    val acquiredAt = datetime("acquired_at")
    val acquiredVia = enumerationByName<PlayerCollectionAcquiredViaType>("acquired_via", 50)
    val playerId = reference("player_id", PlayerTable)
    val cardId = reference("card_id", CardTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class PlayerCollectionRequest(
    val quantity: Int,
    val foil: Boolean,
    val condition: PlayerCollectionConditionType,
    val acquiredAt: java.time.LocalDateTime,
    val acquiredVia: PlayerCollectionAcquiredViaType,
    val playerId: Int,
    val cardId: Int
)

data class PlayerCollectionResponse(
    val id: Int,
    val quantity: Int,
    val foil: Boolean,
    val condition: PlayerCollectionConditionType,
    val acquiredAt: java.time.LocalDateTime,
    val acquiredVia: PlayerCollectionAcquiredViaType,
    val playerId: Int,
    val cardId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toPlayerCollectionResponse() = PlayerCollectionResponse(
    id = this[PlayerCollectionTable.id].value,
    quantity = this[PlayerCollectionTable.quantity],
    foil = this[PlayerCollectionTable.foil],
    condition = this[PlayerCollectionTable.condition],
    acquiredAt = this[PlayerCollectionTable.acquiredAt],
    acquiredVia = this[PlayerCollectionTable.acquiredVia],
    playerId = this[PlayerCollectionTable.playerId].value,
    cardId = this[PlayerCollectionTable.cardId].value,
    createdAt = this[PlayerCollectionTable.createdAt].toString(),
    updatedAt = this[PlayerCollectionTable.updatedAt].toString()
)

object PlayerCollectionRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<PlayerCollectionResponse> = transaction {
        PlayerCollectionTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toPlayerCollectionResponse() }
    }

    fun findById(id: Int): PlayerCollectionResponse? = transaction {
        PlayerCollectionTable.selectAll().where { PlayerCollectionTable.id eq id }.singleOrNull()?.toPlayerCollectionResponse()
    }

    fun create(req: PlayerCollectionRequest): PlayerCollectionResponse = transaction {
        val inserted = PlayerCollectionTable.insertAndGetId {
            it[quantity] = req.quantity
            it[foil] = req.foil
            it[condition] = req.condition
            it[acquiredAt] = req.acquiredAt
            it[acquiredVia] = req.acquiredVia
            it[playerId] = EntityID(req.playerId, PlayerTable)
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        PlayerCollectionTable.selectAll().where { PlayerCollectionTable.id eq inserted }.single().toPlayerCollectionResponse()
    }

    fun update(id: Int, req: PlayerCollectionRequest): PlayerCollectionResponse? = transaction {
        val updated = PlayerCollectionTable.update({ PlayerCollectionTable.id eq id }) {
            it[quantity] = req.quantity
            it[foil] = req.foil
            it[condition] = req.condition
            it[acquiredAt] = req.acquiredAt
            it[acquiredVia] = req.acquiredVia
            it[playerId] = EntityID(req.playerId, PlayerTable)
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        if (updated == 0) return@transaction null
        PlayerCollectionTable.selectAll().where { PlayerCollectionTable.id eq id }.singleOrNull()?.toPlayerCollectionResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        PlayerCollectionTable.deleteWhere { PlayerCollectionTable.id eq id } > 0
    }

}
