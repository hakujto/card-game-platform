package cards_project.tournaments.model

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

import cards_project.tournaments.model.SeasonTable
import cards_project.players.model.PlayerTable

enum class TournamentStatusType {
    DRAFT, REGISTRATION, ONGOING, COMPLETED, CANCELLED
}

enum class TournamentFormatType {
    STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT
}

enum class TournamentTournamentTypeType {
    SWISS, SINGLEELIMINATION, DOUBLEELIMINATION, ROUNDROBIN
}

object TournamentTable : IntIdTable("tournament") {
    val name = varchar("name", 255)
    val description = text("description").nullable()
    val status = enumerationByName<TournamentStatusType>("status", 50)
    val format = enumerationByName<TournamentFormatType>("format", 50)
    val tournamentType = enumerationByName<TournamentTournamentTypeType>("tournament_type", 50)
    val maxPlayers = integer("max_players")
    val entryFee = decimal("entry_fee", 19, 4)
    val prizePool = decimal("prize_pool", 19, 4)
    val startTime = datetime("start_time")
    val endTime = datetime("end_time").nullable()
    val isOnline = bool("is_online")
    val location = varchar("location", 255).nullable()
    val rulesText = text("rules_text").nullable()
    val seasonId = reference("season_id", SeasonTable)
    val organizerId = reference("organizer_id", PlayerTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class TournamentRequest(
    val name: String,
    val description: String? = null,
    val status: TournamentStatusType,
    val format: TournamentFormatType,
    val tournamentType: TournamentTournamentTypeType,
    val maxPlayers: Int,
    val entryFee: java.math.BigDecimal,
    val prizePool: java.math.BigDecimal,
    val startTime: java.time.LocalDateTime,
    val endTime: java.time.LocalDateTime? = null,
    val isOnline: Boolean,
    val location: String? = null,
    val rulesText: String? = null,
    val seasonId: Int,
    val organizerId: Int
)

data class TournamentResponse(
    val id: Int,
    val name: String,
    val description: String? = null,
    val status: TournamentStatusType,
    val format: TournamentFormatType,
    val tournamentType: TournamentTournamentTypeType,
    val maxPlayers: Int,
    val entryFee: java.math.BigDecimal,
    val prizePool: java.math.BigDecimal,
    val startTime: java.time.LocalDateTime,
    val endTime: java.time.LocalDateTime? = null,
    val isOnline: Boolean,
    val location: String? = null,
    val rulesText: String? = null,
    val seasonId: Int,
    val organizerId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toTournamentResponse() = TournamentResponse(
    id = this[TournamentTable.id].value,
    name = this[TournamentTable.name],
    description = this[TournamentTable.description],
    status = this[TournamentTable.status],
    format = this[TournamentTable.format],
    tournamentType = this[TournamentTable.tournamentType],
    maxPlayers = this[TournamentTable.maxPlayers],
    entryFee = this[TournamentTable.entryFee],
    prizePool = this[TournamentTable.prizePool],
    startTime = this[TournamentTable.startTime],
    endTime = this[TournamentTable.endTime],
    isOnline = this[TournamentTable.isOnline],
    location = this[TournamentTable.location],
    rulesText = this[TournamentTable.rulesText],
    seasonId = this[TournamentTable.seasonId].value,
    organizerId = this[TournamentTable.organizerId].value,
    createdAt = this[TournamentTable.createdAt].toString(),
    updatedAt = this[TournamentTable.updatedAt].toString()
)

object TournamentRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<TournamentResponse> = transaction {
        val query = if (q != null) {
            TournamentTable.selectAll().where { (TournamentTable.name like "%${q}%") or (TournamentTable.description like "%${q}%") }
        } else {
            TournamentTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toTournamentResponse() }
    }

    fun findById(id: Int): TournamentResponse? = transaction {
        TournamentTable.selectAll().where { TournamentTable.id eq id }.singleOrNull()?.toTournamentResponse()
    }

    fun create(req: TournamentRequest): TournamentResponse = transaction {
        val inserted = TournamentTable.insertAndGetId {
            it[name] = req.name
            it[description] = req.description
            it[status] = req.status
            it[format] = req.format
            it[tournamentType] = req.tournamentType
            it[maxPlayers] = req.maxPlayers
            it[entryFee] = req.entryFee
            it[prizePool] = req.prizePool
            it[startTime] = req.startTime
            it[endTime] = req.endTime
            it[isOnline] = req.isOnline
            it[location] = req.location
            it[rulesText] = req.rulesText
            it[seasonId] = EntityID(req.seasonId, SeasonTable)
            it[organizerId] = EntityID(req.organizerId, PlayerTable)
        }
        TournamentTable.selectAll().where { TournamentTable.id eq inserted }.single().toTournamentResponse()
    }

    fun update(id: Int, req: TournamentRequest): TournamentResponse? = transaction {
        val updated = TournamentTable.update({ TournamentTable.id eq id }) {
            it[name] = req.name
            it[description] = req.description
            it[status] = req.status
            it[format] = req.format
            it[tournamentType] = req.tournamentType
            it[maxPlayers] = req.maxPlayers
            it[entryFee] = req.entryFee
            it[prizePool] = req.prizePool
            it[startTime] = req.startTime
            it[endTime] = req.endTime
            it[isOnline] = req.isOnline
            it[location] = req.location
            it[rulesText] = req.rulesText
            it[seasonId] = EntityID(req.seasonId, SeasonTable)
            it[organizerId] = EntityID(req.organizerId, PlayerTable)
        }
        if (updated == 0) return@transaction null
        TournamentTable.selectAll().where { TournamentTable.id eq id }.singleOrNull()?.toTournamentResponse()
    }

}
