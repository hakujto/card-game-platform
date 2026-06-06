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

import cards_project.cards.model.CardSetTable

enum class CardCardTypeType {
    CREATURE, SPELL, LAND, ARTIFACT, ENCHANTMENT, PLANESWALKER
}

enum class CardRarityType {
    COMMON, UNCOMMON, RARE, MYTHICRARE, LEGENDARY
}

enum class CardManaColorsType {
    WHITE, BLUE, BLACK, RED, GREEN, COLORLESS
}

enum class CardLegalFormatsType {
    STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT
}

object CardTable : IntIdTable("card") {
    val name = varchar("name", 255)
    val cardType = enumerationByName<CardCardTypeType>("card_type", 50)
    val rarity = enumerationByName<CardRarityType>("rarity", 50)
    val manaCost = integer("mana_cost")
    val manaColors = enumerationByName<CardManaColorsType>("mana_colors", 50)
    val attack = integer("attack").nullable()
    val defense = integer("defense").nullable()
    val loyalty = integer("loyalty").nullable()
    val description = text("description")
    val flavorText = text("flavor_text").nullable()
    val imageUrl = text("image_url").nullable()
    val artistName = varchar("artist_name", 255).nullable()
    val legalFormats = enumerationByName<CardLegalFormatsType>("legal_formats", 50)
    val isBanned = bool("is_banned")
    val isRestricted = bool("is_restricted")
    val powerLevel = integer("power_level")
    val setId = reference("set_id", CardSetTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class CardRequest(
    val name: String,
    val cardType: CardCardTypeType,
    val rarity: CardRarityType,
    val manaCost: Int,
    val manaColors: CardManaColorsType,
    val attack: Int? = null,
    val defense: Int? = null,
    val loyalty: Int? = null,
    val description: String,
    val flavorText: String? = null,
    val imageUrl: String? = null,
    val artistName: String? = null,
    val legalFormats: CardLegalFormatsType,
    val isBanned: Boolean,
    val isRestricted: Boolean,
    val powerLevel: Int,
    val setId: Int
)

data class CardResponse(
    val id: Int,
    val name: String,
    val cardType: CardCardTypeType,
    val rarity: CardRarityType,
    val manaCost: Int,
    val manaColors: CardManaColorsType,
    val attack: Int? = null,
    val defense: Int? = null,
    val loyalty: Int? = null,
    val description: String,
    val flavorText: String? = null,
    val imageUrl: String? = null,
    val artistName: String? = null,
    val legalFormats: CardLegalFormatsType,
    val isBanned: Boolean,
    val isRestricted: Boolean,
    val powerLevel: Int,
    val setId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toCardResponse() = CardResponse(
    id = this[CardTable.id].value,
    name = this[CardTable.name],
    cardType = this[CardTable.cardType],
    rarity = this[CardTable.rarity],
    manaCost = this[CardTable.manaCost],
    manaColors = this[CardTable.manaColors],
    attack = this[CardTable.attack],
    defense = this[CardTable.defense],
    loyalty = this[CardTable.loyalty],
    description = this[CardTable.description],
    flavorText = this[CardTable.flavorText],
    imageUrl = this[CardTable.imageUrl],
    artistName = this[CardTable.artistName],
    legalFormats = this[CardTable.legalFormats],
    isBanned = this[CardTable.isBanned],
    isRestricted = this[CardTable.isRestricted],
    powerLevel = this[CardTable.powerLevel],
    setId = this[CardTable.setId].value,
    createdAt = this[CardTable.createdAt].toString(),
    updatedAt = this[CardTable.updatedAt].toString()
)

object CardRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<CardResponse> = transaction {
        val query = if (q != null) {
            CardTable.selectAll().where { (CardTable.name like "%${q}%") or (CardTable.artistName like "%${q}%") }
        } else {
            CardTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toCardResponse() }
    }

    fun findById(id: Int): CardResponse? = transaction {
        CardTable.selectAll().where { CardTable.id eq id }.singleOrNull()?.toCardResponse()
    }

    fun create(req: CardRequest): CardResponse = transaction {
        val inserted = CardTable.insertAndGetId {
            it[name] = req.name
            it[cardType] = req.cardType
            it[rarity] = req.rarity
            it[manaCost] = req.manaCost
            it[manaColors] = req.manaColors
            it[attack] = req.attack
            it[defense] = req.defense
            it[loyalty] = req.loyalty
            it[description] = req.description
            it[flavorText] = req.flavorText
            it[imageUrl] = req.imageUrl
            it[artistName] = req.artistName
            it[legalFormats] = req.legalFormats
            it[isBanned] = req.isBanned
            it[isRestricted] = req.isRestricted
            it[powerLevel] = req.powerLevel
            it[setId] = EntityID(req.setId, CardSetTable)
        }
        CardTable.selectAll().where { CardTable.id eq inserted }.single().toCardResponse()
    }

    fun update(id: Int, req: CardRequest): CardResponse? = transaction {
        val updated = CardTable.update({ CardTable.id eq id }) {
            it[name] = req.name
            it[cardType] = req.cardType
            it[rarity] = req.rarity
            it[manaCost] = req.manaCost
            it[manaColors] = req.manaColors
            it[attack] = req.attack
            it[defense] = req.defense
            it[loyalty] = req.loyalty
            it[description] = req.description
            it[flavorText] = req.flavorText
            it[imageUrl] = req.imageUrl
            it[artistName] = req.artistName
            it[legalFormats] = req.legalFormats
            it[isBanned] = req.isBanned
            it[isRestricted] = req.isRestricted
            it[powerLevel] = req.powerLevel
            it[setId] = EntityID(req.setId, CardSetTable)
        }
        if (updated == 0) return@transaction null
        CardTable.selectAll().where { CardTable.id eq id }.singleOrNull()?.toCardResponse()
    }

}
