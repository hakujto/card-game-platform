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
import cards_project.players.model.*
import cards_project.marketplace.model.*
import cards_project.content.model.*

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
    val publicId = uuid("public_id").uniqueIndex()
    val name = varchar("name", 255)
    val cardType = enumerationByName<CardCardTypeType>("card_type", 50).default(CardCardTypeType.CREATURE)
    val rarity = enumerationByName<CardRarityType>("rarity", 50).default(CardRarityType.COMMON)
    val manaCost = integer("mana_cost").default(0)
    val manaColors = enumerationByName<CardManaColorsType>("mana_colors", 50)
    val attack = integer("attack").nullable()
    val defense = integer("defense").nullable()
    val loyalty = integer("loyalty").nullable()
    val description = text("description")
    val flavorText = text("flavor_text").nullable()
    val imageUrl = text("image_url").nullable()
    val artistName = varchar("artist_name", 255).nullable()
    val legalFormats = enumerationByName<CardLegalFormatsType>("legal_formats", 50)
    val isBanned = bool("is_banned").default(false)
    val isRestricted = bool("is_restricted").default(false)
    val powerLevel = integer("power_level").default(1)
    val metadata = text("metadata").nullable()
    val totalCopiesInCirculation = long("total_copies_in_circulation").default(0)
    val setId = reference("set_id", CardSetTable, onDelete = ReferenceOption.RESTRICT)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class CardRequest(
    val publicId: java.util.UUID,
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
    val powerLevel: Int,
    val metadata: String? = null,
    val totalCopiesInCirculation: Long,
    val setId: Int
)

data class CardPatchRequest(
    val flavorText: String? = null,
    val artistName: String? = null
)

data class CardResponse(
    val id: Int,
    val publicId: java.util.UUID,
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
    val metadata: String? = null,
    val totalCopiesInCirculation: Long,
    val setId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toCardResponse() = CardResponse(
    id = this[CardTable.id].value,
    publicId = this[CardTable.publicId],
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
    metadata = this[CardTable.metadata],
    totalCopiesInCirculation = this[CardTable.totalCopiesInCirculation],
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
            it[publicId] = req.publicId
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
            it[powerLevel] = req.powerLevel
            it[metadata] = req.metadata
            it[totalCopiesInCirculation] = req.totalCopiesInCirculation
            it[setId] = EntityID(req.setId, CardSetTable)
        }
        CardTable.selectAll().where { CardTable.id eq inserted }.single().toCardResponse()
    }

    fun update(id: Int, req: CardRequest): CardResponse? = transaction {
        val updated = CardTable.update({ CardTable.id eq id }) {
            it[publicId] = req.publicId
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
            it[powerLevel] = req.powerLevel
            it[metadata] = req.metadata
            it[totalCopiesInCirculation] = req.totalCopiesInCirculation
            it[setId] = EntityID(req.setId, CardSetTable)
        }
        if (updated == 0) return@transaction null
        CardTable.selectAll().where { CardTable.id eq id }.singleOrNull()?.toCardResponse()
    }

    fun patch(id: Int, req: CardPatchRequest): CardResponse? = transaction {
        if (req.flavorText != null || req.artistName != null) {
            CardTable.update({ CardTable.id eq id }) {
                req.flavorText?.let { v -> it[flavorText] = v }
                req.artistName?.let { v -> it[artistName] = v }
            }
        }
        CardTable.selectAll().where { CardTable.id eq id }.singleOrNull()?.toCardResponse()
    }

    fun rulings(id: Int): List<CardRulingResponse> = transaction {
        CardRulingTable.selectAll().where { CardRulingTable.cardId eq id }.map { it.toCardRulingResponse() }
    }

    fun abilities(id: Int): List<CardAbilityResponse> = transaction {
        CardAbilityTable.selectAll().where { CardAbilityTable.cardId eq id }.map { it.toCardAbilityResponse() }
    }

    fun deckCards(id: Int): List<DeckCardResponse> = transaction {
        DeckCardTable.selectAll().where { DeckCardTable.cardId eq id }.map { it.toDeckCardResponse() }
    }

    fun sideboardDecks(id: Int): List<DeckSideboardCardResponse> = transaction {
        DeckSideboardCardTable.selectAll().where { DeckSideboardCardTable.cardId eq id }.map { it.toDeckSideboardCardResponse() }
    }

    fun playerCollections(id: Int): List<PlayerCollectionResponse> = transaction {
        PlayerCollectionTable.selectAll().where { PlayerCollectionTable.cardId eq id }.map { it.toPlayerCollectionResponse() }
    }

    fun craftingRecipes(id: Int): List<CraftingRecipeResponse> = transaction {
        CraftingRecipeTable.selectAll().where { CraftingRecipeTable.resultCardId eq id }.map { it.toCraftingRecipeResponse() }
    }

    fun usedInRecipes(id: Int): List<CraftingIngredientResponse> = transaction {
        CraftingIngredientTable.selectAll().where { CraftingIngredientTable.cardId eq id }.map { it.toCraftingIngredientResponse() }
    }

    fun shopProduct(id: Int): ProductResponse? = transaction {
        ProductTable.selectAll().where { ProductTable.cardId eq id }.singleOrNull()?.toProductResponse()
    }

    fun tradeListings(id: Int): List<TradeListingResponse> = transaction {
        TradeListingTable.selectAll().where { TradeListingTable.cardId eq id }.map { it.toTradeListingResponse() }
    }

    fun priceHistory(id: Int): List<CardPriceHistoryResponse> = transaction {
        CardPriceHistoryTable.selectAll().where { CardPriceHistoryTable.cardId eq id }.map { it.toCardPriceHistoryResponse() }
    }

    fun draftPicks(id: Int): List<DraftPickResponse> = transaction {
        DraftPickTable.selectAll().where { DraftPickTable.cardId eq id }.map { it.toDraftPickResponse() }
    }

}

object CardAuditLogTable : IntIdTable("cards_audit_log") {
    val recordId = integer("record_id")
    val field    = varchar("field", 100)
    val oldValue = text("old_value").nullable()
    val newValue = text("new_value").nullable()
    val changedAt = datetime("changed_at").defaultExpression(CurrentDateTime)
}

data class CardAuditLog(
    val id: Int,
    val recordId: Int,
    val field: String,
    val oldValue: String?,
    val newValue: String?,
    val changedAt: String
)
