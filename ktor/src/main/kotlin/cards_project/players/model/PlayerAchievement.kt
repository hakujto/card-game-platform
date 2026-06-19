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
import cards_project.players.model.AchievementTable

object PlayerAchievementTable : IntIdTable("player_achievement") {
    val earnedAt = datetime("earned_at")
    val progress = integer("progress").default(0)
    val isCompleted = bool("is_completed").default(false)
    val playerId = reference("player_id", PlayerTable, onDelete = ReferenceOption.CASCADE)
    val achievementId = reference("achievement_id", AchievementTable, onDelete = ReferenceOption.RESTRICT)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class PlayerAchievementRequest(
    val earnedAt: java.time.LocalDateTime,
    val progress: Int,
    val isCompleted: Boolean,
    val playerId: Int,
    val achievementId: Int
)

data class PlayerAchievementResponse(
    val id: Int,
    val earnedAt: java.time.LocalDateTime,
    val progress: Int,
    val isCompleted: Boolean,
    val playerId: Int,
    val achievementId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toPlayerAchievementResponse() = PlayerAchievementResponse(
    id = this[PlayerAchievementTable.id].value,
    earnedAt = this[PlayerAchievementTable.earnedAt],
    progress = this[PlayerAchievementTable.progress],
    isCompleted = this[PlayerAchievementTable.isCompleted],
    playerId = this[PlayerAchievementTable.playerId].value,
    achievementId = this[PlayerAchievementTable.achievementId].value,
    createdAt = this[PlayerAchievementTable.createdAt].toString(),
    updatedAt = this[PlayerAchievementTable.updatedAt].toString()
)

object PlayerAchievementRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<PlayerAchievementResponse> = transaction {
        PlayerAchievementTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toPlayerAchievementResponse() }
    }

    fun findById(id: Int): PlayerAchievementResponse? = transaction {
        PlayerAchievementTable.selectAll().where { PlayerAchievementTable.id eq id }.singleOrNull()?.toPlayerAchievementResponse()
    }

}
