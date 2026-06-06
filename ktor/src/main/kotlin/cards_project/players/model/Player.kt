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

enum class PlayerRankType {
    BRONZE, SILVER, GOLD, PLATINUM, DIAMOND, MASTER, GRANDMASTER
}

enum class PlayerPreferredFormatType {
    STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT
}

object PlayerTable : IntIdTable("player") {
    val displayName = varchar("display_name", 255)
    val rank = enumerationByName<PlayerRankType>("rank", 50)
    val rating = integer("rating")
    val peakRating = integer("peak_rating")
    val bio = text("bio").nullable()
    val countryCode = varchar("country_code", 255).nullable()
    val avatarUrl = text("avatar_url").nullable()
    val preferredFormat = enumerationByName<PlayerPreferredFormatType>("preferred_format", 50).nullable()
    val isVerified = bool("is_verified")
    val lastActiveAt = datetime("last_active_at").nullable()
    val userId = integer("user_id")
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class PlayerRequest(
    val displayName: String,
    val rank: PlayerRankType,
    val rating: Int,
    val peakRating: Int,
    val bio: String? = null,
    val countryCode: String? = null,
    val avatarUrl: String? = null,
    val preferredFormat: PlayerPreferredFormatType? = null,
    val isVerified: Boolean,
    val lastActiveAt: java.time.LocalDateTime? = null,
    val userId: Int
)

data class PlayerResponse(
    val id: Int,
    val displayName: String,
    val rank: PlayerRankType,
    val rating: Int,
    val peakRating: Int,
    val bio: String? = null,
    val countryCode: String? = null,
    val avatarUrl: String? = null,
    val preferredFormat: PlayerPreferredFormatType? = null,
    val isVerified: Boolean,
    val lastActiveAt: java.time.LocalDateTime? = null,
    val userId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toPlayerResponse() = PlayerResponse(
    id = this[PlayerTable.id].value,
    displayName = this[PlayerTable.displayName],
    rank = this[PlayerTable.rank],
    rating = this[PlayerTable.rating],
    peakRating = this[PlayerTable.peakRating],
    bio = this[PlayerTable.bio],
    countryCode = this[PlayerTable.countryCode],
    avatarUrl = this[PlayerTable.avatarUrl],
    preferredFormat = this[PlayerTable.preferredFormat],
    isVerified = this[PlayerTable.isVerified],
    lastActiveAt = this[PlayerTable.lastActiveAt],
    userId = this[PlayerTable.userId],
    createdAt = this[PlayerTable.createdAt].toString(),
    updatedAt = this[PlayerTable.updatedAt].toString()
)

object PlayerRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<PlayerResponse> = transaction {
        val query = if (q != null) {
            PlayerTable.selectAll().where { (PlayerTable.displayName like "%${q}%") }
        } else {
            PlayerTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toPlayerResponse() }
    }

    fun findById(id: Int): PlayerResponse? = transaction {
        PlayerTable.selectAll().where { PlayerTable.id eq id }.singleOrNull()?.toPlayerResponse()
    }

    fun create(req: PlayerRequest): PlayerResponse = transaction {
        val inserted = PlayerTable.insertAndGetId {
            it[displayName] = req.displayName
            it[rank] = req.rank
            it[rating] = req.rating
            it[peakRating] = req.peakRating
            it[bio] = req.bio
            it[countryCode] = req.countryCode
            it[avatarUrl] = req.avatarUrl
            it[preferredFormat] = req.preferredFormat
            it[isVerified] = req.isVerified
            it[lastActiveAt] = req.lastActiveAt
            it[userId] = req.userId
        }
        PlayerTable.selectAll().where { PlayerTable.id eq inserted }.single().toPlayerResponse()
    }

    fun update(id: Int, req: PlayerRequest): PlayerResponse? = transaction {
        val updated = PlayerTable.update({ PlayerTable.id eq id }) {
            it[displayName] = req.displayName
            it[rank] = req.rank
            it[rating] = req.rating
            it[peakRating] = req.peakRating
            it[bio] = req.bio
            it[countryCode] = req.countryCode
            it[avatarUrl] = req.avatarUrl
            it[preferredFormat] = req.preferredFormat
            it[isVerified] = req.isVerified
            it[lastActiveAt] = req.lastActiveAt
            it[userId] = req.userId
        }
        if (updated == 0) return@transaction null
        PlayerTable.selectAll().where { PlayerTable.id eq id }.singleOrNull()?.toPlayerResponse()
    }

}
