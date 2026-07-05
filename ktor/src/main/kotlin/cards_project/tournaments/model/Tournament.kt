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
import cards_project.players.model.*
import cards_project.content.model.*

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
    val publicId = uuid("public_id").uniqueIndex()
    val name = varchar("name", 255)
    val description = text("description").nullable()
    val status = enumerationByName<TournamentStatusType>("status", 50).default(TournamentStatusType.DRAFT)
    val bracketData = text("bracket_data").nullable()
    val format = enumerationByName<TournamentFormatType>("format", 50).default(TournamentFormatType.STANDARD)
    val tournamentType = enumerationByName<TournamentTournamentTypeType>("tournament_type", 50).default(TournamentTournamentTypeType.SWISS)
    val maxPlayers = integer("max_players")
    val entryFee = decimal("entry_fee", 19, 4).default(java.math.BigDecimal("0"))
    val prizePool = decimal("prize_pool", 19, 4).default(java.math.BigDecimal("0"))
    val startTime = datetime("start_time")
    val endTime = datetime("end_time").nullable()
    val isOnline = bool("is_online").default(true)
    val location = varchar("location", 255).nullable()
    val rulesText = text("rules_text").nullable()
    val seasonId = reference("season_id", SeasonTable, onDelete = ReferenceOption.RESTRICT)
    val organizerId = reference("organizer_id", PlayerTable, onDelete = ReferenceOption.RESTRICT)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class TournamentRequest(
    val publicId: java.util.UUID,
    val name: String,
    val description: String? = null,
    val bracketData: String? = null,
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

data class TournamentPatchRequest(
    val description: String? = null,
    val location: String? = null,
    val rulesText: String? = null
)

data class TournamentResponse(
    val id: Int,
    val publicId: java.util.UUID,
    val name: String,
    val description: String? = null,
    val status: TournamentStatusType,
    val bracketData: String? = null,
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
    publicId = this[TournamentTable.publicId],
    name = this[TournamentTable.name],
    description = this[TournamentTable.description],
    status = this[TournamentTable.status],
    bracketData = this[TournamentTable.bracketData],
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
            it[publicId] = req.publicId
            it[name] = req.name
            it[description] = req.description
            it[bracketData] = req.bracketData
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
            it[publicId] = req.publicId
            it[name] = req.name
            it[description] = req.description
            it[bracketData] = req.bracketData
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

    fun patch(id: Int, req: TournamentPatchRequest): TournamentResponse? = transaction {
        if (req.description != null || req.location != null || req.rulesText != null) {
            TournamentTable.update({ TournamentTable.id eq id }) {
                req.description?.let { v -> it[description] = v }
                req.location?.let { v -> it[location] = v }
                req.rulesText?.let { v -> it[rulesText] = v }
            }
        }
        TournamentTable.selectAll().where { TournamentTable.id eq id }.singleOrNull()?.toTournamentResponse()
    }

    fun updateStatus(id: Int, newStatus: String): TournamentResponse? = transaction {
        val updated = TournamentTable.update({ TournamentTable.id eq id }) {
            it[status] = TournamentStatusType.valueOf(newStatus)
        }
        if (updated == 0) return@transaction null
        TournamentTable.selectAll().where { TournamentTable.id eq id }.singleOrNull()?.toTournamentResponse()
    }

    fun judgeAssignments(id: Int): List<TournamentJudgeResponse> = transaction {
        TournamentJudgeTable.selectAll().where { TournamentJudgeTable.tournamentId eq id }.map { it.toTournamentJudgeResponse() }
    }

    fun registrations(id: Int): List<TournamentRegistrationResponse> = transaction {
        TournamentRegistrationTable.selectAll().where { TournamentRegistrationTable.tournamentId eq id }.map { it.toTournamentRegistrationResponse() }
    }

    fun rounds(id: Int): List<TournamentRoundResponse> = transaction {
        TournamentRoundTable.selectAll().where { TournamentRoundTable.tournamentId eq id }.map { it.toTournamentRoundResponse() }
    }

    fun prizes(id: Int): List<TournamentPrizeResponse> = transaction {
        TournamentPrizeTable.selectAll().where { TournamentPrizeTable.tournamentId eq id }.map { it.toTournamentPrizeResponse() }
    }

    fun streams(id: Int): List<StreamResponse> = transaction {
        StreamTable.selectAll().where { StreamTable.tournamentId eq id }.map { it.toStreamResponse() }
    }

}

object TournamentAuditLogTable : IntIdTable("tournaments_audit_log") {
    val recordId = integer("record_id")
    val field    = varchar("field", 100)
    val oldValue = text("old_value").nullable()
    val newValue = text("new_value").nullable()
    val changedAt = datetime("changed_at").defaultExpression(CurrentDateTime)
}

data class TournamentAuditLog(
    val id: Int,
    val recordId: Int,
    val field: String,
    val oldValue: String?,
    val newValue: String?,
    val changedAt: String
)

data class TournamentCompleted(
    val tournamentId: Int,
    val seasonId: Int,
    val completedAt: java.time.LocalDateTime
)

data class PlayerRegistered(
    val tournamentId: Int,
    val playerId: Int,
    val registeredAt: java.time.LocalDateTime
)
