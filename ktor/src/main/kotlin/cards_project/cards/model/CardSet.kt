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

enum class CardSetSetTypeType {
    CORE, EXPANSION, SUPPLEMENTAL, MASTERS, DRAFT
}

object CardSetTable : IntIdTable("card_set") {
    val name = varchar("name", 255)
    val code = varchar("code", 255)
    val releaseDate = date("release_date")
    val rotationDate = date("rotation_date").nullable()
    val setType = enumerationByName<CardSetSetTypeType>("set_type", 50)
    val totalCards = integer("total_cards")
    val isRotated = bool("is_rotated")
    val description = text("description").nullable()
    val logoUrl = text("logo_url").nullable()
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class CardSetRequest(
    val name: String,
    val code: String,
    val releaseDate: java.time.LocalDate,
    val rotationDate: java.time.LocalDate? = null,
    val setType: CardSetSetTypeType,
    val totalCards: Int,
    val isRotated: Boolean,
    val description: String? = null,
    val logoUrl: String? = null
)

data class CardSetResponse(
    val id: Int,
    val name: String,
    val code: String,
    val releaseDate: java.time.LocalDate,
    val rotationDate: java.time.LocalDate? = null,
    val setType: CardSetSetTypeType,
    val totalCards: Int,
    val isRotated: Boolean,
    val description: String? = null,
    val logoUrl: String? = null,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toCardSetResponse() = CardSetResponse(
    id = this[CardSetTable.id].value,
    name = this[CardSetTable.name],
    code = this[CardSetTable.code],
    releaseDate = this[CardSetTable.releaseDate],
    rotationDate = this[CardSetTable.rotationDate],
    setType = this[CardSetTable.setType],
    totalCards = this[CardSetTable.totalCards],
    isRotated = this[CardSetTable.isRotated],
    description = this[CardSetTable.description],
    logoUrl = this[CardSetTable.logoUrl],
    createdAt = this[CardSetTable.createdAt].toString(),
    updatedAt = this[CardSetTable.updatedAt].toString()
)

object CardSetRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<CardSetResponse> = transaction {
        val query = if (q != null) {
            CardSetTable.selectAll().where { (CardSetTable.name like "%${q}%") or (CardSetTable.code like "%${q}%") }
        } else {
            CardSetTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toCardSetResponse() }
    }

    fun findById(id: Int): CardSetResponse? = transaction {
        CardSetTable.selectAll().where { CardSetTable.id eq id }.singleOrNull()?.toCardSetResponse()
    }

    fun create(req: CardSetRequest): CardSetResponse = transaction {
        val inserted = CardSetTable.insertAndGetId {
            it[name] = req.name
            it[code] = req.code
            it[releaseDate] = req.releaseDate
            it[rotationDate] = req.rotationDate
            it[setType] = req.setType
            it[totalCards] = req.totalCards
            it[isRotated] = req.isRotated
            it[description] = req.description
            it[logoUrl] = req.logoUrl
        }
        CardSetTable.selectAll().where { CardSetTable.id eq inserted }.single().toCardSetResponse()
    }

    fun update(id: Int, req: CardSetRequest): CardSetResponse? = transaction {
        val updated = CardSetTable.update({ CardSetTable.id eq id }) {
            it[name] = req.name
            it[code] = req.code
            it[releaseDate] = req.releaseDate
            it[rotationDate] = req.rotationDate
            it[setType] = req.setType
            it[totalCards] = req.totalCards
            it[isRotated] = req.isRotated
            it[description] = req.description
            it[logoUrl] = req.logoUrl
        }
        if (updated == 0) return@transaction null
        CardSetTable.selectAll().where { CardSetTable.id eq id }.singleOrNull()?.toCardSetResponse()
    }

}
