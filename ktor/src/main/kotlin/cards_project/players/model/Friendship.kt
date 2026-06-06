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

enum class FriendshipStatusType {
    PENDING, ACCEPTED, BLOCKED
}

object FriendshipTable : IntIdTable("friendship") {
    val status = enumerationByName<FriendshipStatusType>("status", 50)
    val requesterId = reference("requester_id", PlayerTable)
    val receiverId = reference("receiver_id", PlayerTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class FriendshipRequest(
    val status: FriendshipStatusType,
    val requesterId: Int,
    val receiverId: Int
)

data class FriendshipResponse(
    val id: Int,
    val status: FriendshipStatusType,
    val requesterId: Int,
    val receiverId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toFriendshipResponse() = FriendshipResponse(
    id = this[FriendshipTable.id].value,
    status = this[FriendshipTable.status],
    requesterId = this[FriendshipTable.requesterId].value,
    receiverId = this[FriendshipTable.receiverId].value,
    createdAt = this[FriendshipTable.createdAt].toString(),
    updatedAt = this[FriendshipTable.updatedAt].toString()
)

object FriendshipRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<FriendshipResponse> = transaction {
        FriendshipTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toFriendshipResponse() }
    }

    fun findById(id: Int): FriendshipResponse? = transaction {
        FriendshipTable.selectAll().where { FriendshipTable.id eq id }.singleOrNull()?.toFriendshipResponse()
    }

    fun create(req: FriendshipRequest): FriendshipResponse = transaction {
        val inserted = FriendshipTable.insertAndGetId {
            it[status] = req.status
            it[requesterId] = EntityID(req.requesterId, PlayerTable)
            it[receiverId] = EntityID(req.receiverId, PlayerTable)
        }
        FriendshipTable.selectAll().where { FriendshipTable.id eq inserted }.single().toFriendshipResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        FriendshipTable.deleteWhere { FriendshipTable.id eq id } > 0
    }

}
