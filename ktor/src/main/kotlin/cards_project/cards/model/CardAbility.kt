package cards_project.cards.model

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

import cards_project.cards.model.CardTable

enum class CardAbilityAbilityTypeType {
    KEYWORD, ACTIVATED, TRIGGERED, STATIC
}

enum class CardAbilityTimingType {
    ANY, SORCERY, INSTANT, COMBAT
}

object CardAbilityTable : IntIdTable("card_ability") {
    val abilityType = enumerationByName<CardAbilityAbilityTypeType>("ability_type", 50).default(CardAbilityAbilityTypeType.KEYWORD)
    val keyword = varchar("keyword", 255).nullable()
    val abilityText = text("ability_text")
    val timing = enumerationByName<CardAbilityTimingType>("timing", 50).nullable()
    val cardId = reference("card_id", CardTable, onDelete = ReferenceOption.CASCADE)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class CardAbilityRequest(
    val abilityType: CardAbilityAbilityTypeType,
    val keyword: String? = null,
    val abilityText: String,
    val timing: CardAbilityTimingType? = null,
    val cardId: Int
)

data class CardAbilityResponse(
    val id: Int,
    val abilityType: CardAbilityAbilityTypeType,
    val keyword: String? = null,
    val abilityText: String,
    val timing: CardAbilityTimingType? = null,
    val cardId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toCardAbilityResponse() = CardAbilityResponse(
    id = this[CardAbilityTable.id].value,
    abilityType = this[CardAbilityTable.abilityType],
    keyword = this[CardAbilityTable.keyword],
    abilityText = this[CardAbilityTable.abilityText],
    timing = this[CardAbilityTable.timing],
    cardId = this[CardAbilityTable.cardId].value,
    createdAt = this[CardAbilityTable.createdAt].toString(),
    updatedAt = this[CardAbilityTable.updatedAt].toString()
)

object CardAbilityRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<CardAbilityResponse> = transaction {
        val query = if (q != null) {
            CardAbilityTable.selectAll().where { (CardAbilityTable.keyword like "%${q}%") or (CardAbilityTable.abilityText like "%${q}%") }
        } else {
            CardAbilityTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toCardAbilityResponse() }
    }

    fun findById(id: Int): CardAbilityResponse? = transaction {
        CardAbilityTable.selectAll().where { CardAbilityTable.id eq id }.singleOrNull()?.toCardAbilityResponse()
    }

    fun create(req: CardAbilityRequest): CardAbilityResponse = transaction {
        val inserted = CardAbilityTable.insertAndGetId {
            it[abilityType] = req.abilityType
            it[keyword] = req.keyword
            it[abilityText] = req.abilityText
            it[timing] = req.timing
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        CardAbilityTable.selectAll().where { CardAbilityTable.id eq inserted }.single().toCardAbilityResponse()
    }

    fun update(id: Int, req: CardAbilityRequest): CardAbilityResponse? = transaction {
        val updated = CardAbilityTable.update({ CardAbilityTable.id eq id }) {
            it[abilityType] = req.abilityType
            it[keyword] = req.keyword
            it[abilityText] = req.abilityText
            it[timing] = req.timing
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        if (updated == 0) return@transaction null
        CardAbilityTable.selectAll().where { CardAbilityTable.id eq id }.singleOrNull()?.toCardAbilityResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        CardAbilityTable.deleteWhere { CardAbilityTable.id eq id } > 0
    }

}
