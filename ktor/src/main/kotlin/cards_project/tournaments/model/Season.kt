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

import cards_project.players.model.*

enum class SeasonFormatType {
    STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT
}

object SeasonTable : IntIdTable("season") {
    val name = varchar("name", 255)
    val startDate = date("start_date")
    val endDate = date("end_date")
    val format = enumerationByName<SeasonFormatType>("format", 50).default(SeasonFormatType.STANDARD)
    val isActive = bool("is_active").default(false)
    val rewardDescription = text("reward_description").nullable()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class SeasonRequest(
    val name: String,
    val startDate: java.time.LocalDate,
    val endDate: java.time.LocalDate,
    val format: SeasonFormatType,
    val isActive: Boolean,
    val rewardDescription: String? = null
)

data class SeasonResponse(
    val id: Int,
    val name: String,
    val startDate: java.time.LocalDate,
    val endDate: java.time.LocalDate,
    val format: SeasonFormatType,
    val isActive: Boolean,
    val rewardDescription: String? = null,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toSeasonResponse() = SeasonResponse(
    id = this[SeasonTable.id].value,
    name = this[SeasonTable.name],
    startDate = this[SeasonTable.startDate],
    endDate = this[SeasonTable.endDate],
    format = this[SeasonTable.format],
    isActive = this[SeasonTable.isActive],
    rewardDescription = this[SeasonTable.rewardDescription],
    createdAt = this[SeasonTable.createdAt].toString(),
    updatedAt = this[SeasonTable.updatedAt].toString()
)

object SeasonRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<SeasonResponse> = transaction {
        val query = if (q != null) {
            SeasonTable.selectAll().where { (SeasonTable.name like "%${q}%") }
        } else {
            SeasonTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toSeasonResponse() }
    }

    fun findById(id: Int): SeasonResponse? = transaction {
        SeasonTable.selectAll().where { SeasonTable.id eq id }.singleOrNull()?.toSeasonResponse()
    }

    fun create(req: SeasonRequest): SeasonResponse = transaction {
        val inserted = SeasonTable.insertAndGetId {
            it[name] = req.name
            it[startDate] = req.startDate
            it[endDate] = req.endDate
            it[format] = req.format
            it[isActive] = req.isActive
            it[rewardDescription] = req.rewardDescription
        }
        SeasonTable.selectAll().where { SeasonTable.id eq inserted }.single().toSeasonResponse()
    }

    fun update(id: Int, req: SeasonRequest): SeasonResponse? = transaction {
        val updated = SeasonTable.update({ SeasonTable.id eq id }) {
            it[name] = req.name
            it[startDate] = req.startDate
            it[endDate] = req.endDate
            it[format] = req.format
            it[isActive] = req.isActive
            it[rewardDescription] = req.rewardDescription
        }
        if (updated == 0) return@transaction null
        SeasonTable.selectAll().where { SeasonTable.id eq id }.singleOrNull()?.toSeasonResponse()
    }

    fun playerStats(id: Int): List<PlayerSeasonStatsResponse> = transaction {
        PlayerSeasonStatsTable.selectAll().where { PlayerSeasonStatsTable.seasonId eq id }.map { it.toPlayerSeasonStatsResponse() }
    }

    fun tournaments(id: Int): List<TournamentResponse> = transaction {
        TournamentTable.selectAll().where { TournamentTable.seasonId eq id }.map { it.toTournamentResponse() }
    }

}
