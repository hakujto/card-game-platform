package cards_project.content.model

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

import cards_project.tournaments.model.TournamentTable
import cards_project.players.model.PlayerTable

enum class StreamStatusType {
    SCHEDULED, LIVE, ENDED
}

enum class StreamPlatformType {
    TWITCH, YOUTUBE, KICKSTREAM, PLATFORM
}

enum class StreamLanguageType {
    EN, DE, FR, IT, ES, JP, PT
}

object StreamTable : IntIdTable("stream") {
    val title = varchar("title", 255)
    val streamUrl = text("stream_url")
    val status = enumerationByName<StreamStatusType>("status", 50)
    val platform = enumerationByName<StreamPlatformType>("platform", 50)
    val language = enumerationByName<StreamLanguageType>("language", 50)
    val isOfficial = bool("is_official")
    val viewerCountPeak = integer("viewer_count_peak")
    val scheduledStart = datetime("scheduled_start")
    val actualStart = datetime("actual_start").nullable()
    val endedAt = datetime("ended_at").nullable()
    val vodUrl = text("vod_url").nullable()
    val tournamentId = reference("tournament_id", TournamentTable).nullable()
    val streamerId = reference("streamer_id", PlayerTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class StreamRequest(
    val title: String,
    val streamUrl: String,
    val status: StreamStatusType,
    val platform: StreamPlatformType,
    val language: StreamLanguageType,
    val isOfficial: Boolean,
    val viewerCountPeak: Int,
    val scheduledStart: java.time.LocalDateTime,
    val actualStart: java.time.LocalDateTime? = null,
    val endedAt: java.time.LocalDateTime? = null,
    val vodUrl: String? = null,
    val tournamentId: Int? = null,
    val streamerId: Int
)

data class StreamResponse(
    val id: Int,
    val title: String,
    val streamUrl: String,
    val status: StreamStatusType,
    val platform: StreamPlatformType,
    val language: StreamLanguageType,
    val isOfficial: Boolean,
    val viewerCountPeak: Int,
    val scheduledStart: java.time.LocalDateTime,
    val actualStart: java.time.LocalDateTime? = null,
    val endedAt: java.time.LocalDateTime? = null,
    val vodUrl: String? = null,
    val tournamentId: Int?,
    val streamerId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toStreamResponse() = StreamResponse(
    id = this[StreamTable.id].value,
    title = this[StreamTable.title],
    streamUrl = this[StreamTable.streamUrl],
    status = this[StreamTable.status],
    platform = this[StreamTable.platform],
    language = this[StreamTable.language],
    isOfficial = this[StreamTable.isOfficial],
    viewerCountPeak = this[StreamTable.viewerCountPeak],
    scheduledStart = this[StreamTable.scheduledStart],
    actualStart = this[StreamTable.actualStart],
    endedAt = this[StreamTable.endedAt],
    vodUrl = this[StreamTable.vodUrl],
    tournamentId = this[StreamTable.tournamentId]?.value,
    streamerId = this[StreamTable.streamerId].value,
    createdAt = this[StreamTable.createdAt].toString(),
    updatedAt = this[StreamTable.updatedAt].toString()
)

object StreamRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<StreamResponse> = transaction {
        val query = if (q != null) {
            StreamTable.selectAll().where { (StreamTable.title like "%${q}%") }
        } else {
            StreamTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toStreamResponse() }
    }

    fun findById(id: Int): StreamResponse? = transaction {
        StreamTable.selectAll().where { StreamTable.id eq id }.singleOrNull()?.toStreamResponse()
    }

    fun create(req: StreamRequest): StreamResponse = transaction {
        val inserted = StreamTable.insertAndGetId {
            it[title] = req.title
            it[streamUrl] = req.streamUrl
            it[status] = req.status
            it[platform] = req.platform
            it[language] = req.language
            it[isOfficial] = req.isOfficial
            it[viewerCountPeak] = req.viewerCountPeak
            it[scheduledStart] = req.scheduledStart
            it[actualStart] = req.actualStart
            it[endedAt] = req.endedAt
            it[vodUrl] = req.vodUrl
            req.tournamentId?.let { v -> it[tournamentId] = EntityID(v, TournamentTable) }
            it[streamerId] = EntityID(req.streamerId, PlayerTable)
        }
        StreamTable.selectAll().where { StreamTable.id eq inserted }.single().toStreamResponse()
    }

    fun update(id: Int, req: StreamRequest): StreamResponse? = transaction {
        val updated = StreamTable.update({ StreamTable.id eq id }) {
            it[title] = req.title
            it[streamUrl] = req.streamUrl
            it[status] = req.status
            it[platform] = req.platform
            it[language] = req.language
            it[isOfficial] = req.isOfficial
            it[viewerCountPeak] = req.viewerCountPeak
            it[scheduledStart] = req.scheduledStart
            it[actualStart] = req.actualStart
            it[endedAt] = req.endedAt
            it[vodUrl] = req.vodUrl
            req.tournamentId?.let { v -> it[tournamentId] = EntityID(v, TournamentTable) }
            it[streamerId] = EntityID(req.streamerId, PlayerTable)
        }
        if (updated == 0) return@transaction null
        StreamTable.selectAll().where { StreamTable.id eq id }.singleOrNull()?.toStreamResponse()
    }

}
