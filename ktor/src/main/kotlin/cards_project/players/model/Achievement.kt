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

enum class AchievementRarityType {
    COMMON, UNCOMMON, RARE, EPIC, LEGENDARY
}

object AchievementTable : IntIdTable("achievement") {
    val name = varchar("name", 255)
    val description = text("description")
    val iconUrl = text("icon_url").nullable()
    val points = integer("points")
    val rarity = enumerationByName<AchievementRarityType>("rarity", 50)
    val isHidden = bool("is_hidden")
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class AchievementRequest(
    val name: String,
    val description: String,
    val iconUrl: String? = null,
    val points: Int,
    val rarity: AchievementRarityType,
    val isHidden: Boolean
)

data class AchievementResponse(
    val id: Int,
    val name: String,
    val description: String,
    val iconUrl: String? = null,
    val points: Int,
    val rarity: AchievementRarityType,
    val isHidden: Boolean,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toAchievementResponse() = AchievementResponse(
    id = this[AchievementTable.id].value,
    name = this[AchievementTable.name],
    description = this[AchievementTable.description],
    iconUrl = this[AchievementTable.iconUrl],
    points = this[AchievementTable.points],
    rarity = this[AchievementTable.rarity],
    isHidden = this[AchievementTable.isHidden],
    createdAt = this[AchievementTable.createdAt].toString(),
    updatedAt = this[AchievementTable.updatedAt].toString()
)

object AchievementRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<AchievementResponse> = transaction {
        val query = if (q != null) {
            AchievementTable.selectAll().where { (AchievementTable.name like "%${q}%") or (AchievementTable.description like "%${q}%") }
        } else {
            AchievementTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toAchievementResponse() }
    }

    fun findById(id: Int): AchievementResponse? = transaction {
        AchievementTable.selectAll().where { AchievementTable.id eq id }.singleOrNull()?.toAchievementResponse()
    }

    fun create(req: AchievementRequest): AchievementResponse = transaction {
        val inserted = AchievementTable.insertAndGetId {
            it[name] = req.name
            it[description] = req.description
            it[iconUrl] = req.iconUrl
            it[points] = req.points
            it[rarity] = req.rarity
            it[isHidden] = req.isHidden
        }
        AchievementTable.selectAll().where { AchievementTable.id eq inserted }.single().toAchievementResponse()
    }

    fun update(id: Int, req: AchievementRequest): AchievementResponse? = transaction {
        val updated = AchievementTable.update({ AchievementTable.id eq id }) {
            it[name] = req.name
            it[description] = req.description
            it[iconUrl] = req.iconUrl
            it[points] = req.points
            it[rarity] = req.rarity
            it[isHidden] = req.isHidden
        }
        if (updated == 0) return@transaction null
        AchievementTable.selectAll().where { AchievementTable.id eq id }.singleOrNull()?.toAchievementResponse()
    }

}
