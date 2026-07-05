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

import cards_project.players.model.*
import cards_project.tournaments.model.*
import cards_project.content.model.*

enum class DeckFormatType {
    STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT
}

enum class DeckArchetypeType {
    AGGRO, CONTROL, MIDRANGE, COMBO, PRISON, TEMPO
}

object DeckTable : IntIdTable("deck") {
    val name = varchar("name", 255)
    val description = text("description").nullable()
    val format = enumerationByName<DeckFormatType>("format", 50).default(DeckFormatType.STANDARD)
    val isPublic = bool("is_public").default(false)
    val isTournamentLegal = bool("is_tournament_legal").default(false)
    val archetype = enumerationByName<DeckArchetypeType>("archetype", 50).nullable()
    val wins = integer("wins").default(0)
    val losses = integer("losses").default(0)
    val draws = integer("draws").default(0)
    val playerId = reference("player_id", PlayerTable, onDelete = ReferenceOption.CASCADE)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class DeckRequest(
    val name: String,
    val description: String? = null,
    val format: DeckFormatType,
    val isPublic: Boolean,
    val isTournamentLegal: Boolean,
    val archetype: DeckArchetypeType? = null,
    val playerId: Int
)

data class DeckPatchRequest(
    val name: String? = null,
    val description: String? = null,
    val archetype: DeckArchetypeType? = null
)

data class DeckResponse(
    val id: Int,
    val name: String,
    val description: String? = null,
    val format: DeckFormatType,
    val isPublic: Boolean,
    val isTournamentLegal: Boolean,
    val archetype: DeckArchetypeType? = null,
    val wins: Int,
    val losses: Int,
    val draws: Int,
    val playerId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toDeckResponse() = DeckResponse(
    id = this[DeckTable.id].value,
    name = this[DeckTable.name],
    description = this[DeckTable.description],
    format = this[DeckTable.format],
    isPublic = this[DeckTable.isPublic],
    isTournamentLegal = this[DeckTable.isTournamentLegal],
    archetype = this[DeckTable.archetype],
    wins = this[DeckTable.wins],
    losses = this[DeckTable.losses],
    draws = this[DeckTable.draws],
    playerId = this[DeckTable.playerId].value,
    createdAt = this[DeckTable.createdAt].toString(),
    updatedAt = this[DeckTable.updatedAt].toString()
)

object DeckRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<DeckResponse> = transaction {
        val query = if (q != null) {
            DeckTable.selectAll().where { (DeckTable.name like "%${q}%") or (DeckTable.description like "%${q}%") }
        } else {
            DeckTable.selectAll()
        }
        query.limit(limit).offset(skip.toLong()).map { it.toDeckResponse() }
    }

    fun findById(id: Int): DeckResponse? = transaction {
        DeckTable.selectAll().where { DeckTable.id eq id }.singleOrNull()?.toDeckResponse()
    }

    fun create(req: DeckRequest): DeckResponse = transaction {
        val inserted = DeckTable.insertAndGetId {
            it[name] = req.name
            it[description] = req.description
            it[format] = req.format
            it[isPublic] = req.isPublic
            it[isTournamentLegal] = req.isTournamentLegal
            it[archetype] = req.archetype
            it[playerId] = EntityID(req.playerId, PlayerTable)
        }
        DeckTable.selectAll().where { DeckTable.id eq inserted }.single().toDeckResponse()
    }

    fun update(id: Int, req: DeckRequest): DeckResponse? = transaction {
        val updated = DeckTable.update({ DeckTable.id eq id }) {
            it[name] = req.name
            it[description] = req.description
            it[format] = req.format
            it[isPublic] = req.isPublic
            it[isTournamentLegal] = req.isTournamentLegal
            it[archetype] = req.archetype
            it[playerId] = EntityID(req.playerId, PlayerTable)
        }
        if (updated == 0) return@transaction null
        DeckTable.selectAll().where { DeckTable.id eq id }.singleOrNull()?.toDeckResponse()
    }

    fun patch(id: Int, req: DeckPatchRequest): DeckResponse? = transaction {
        if (req.name != null || req.description != null || req.archetype != null) {
            DeckTable.update({ DeckTable.id eq id }) {
                req.name?.let { v -> it[name] = v }
                req.description?.let { v -> it[description] = v }
                req.archetype?.let { v -> it[archetype] = v }
            }
        }
        DeckTable.selectAll().where { DeckTable.id eq id }.singleOrNull()?.toDeckResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        DeckTable.deleteWhere { DeckTable.id eq id } > 0
    }

    fun deckCards(id: Int): List<DeckCardResponse> = transaction {
        DeckCardTable.selectAll().where { DeckCardTable.deckId eq id }.map { it.toDeckCardResponse() }
    }

    fun sideboardCards(id: Int): List<DeckSideboardCardResponse> = transaction {
        DeckSideboardCardTable.selectAll().where { DeckSideboardCardTable.deckId eq id }.map { it.toDeckSideboardCardResponse() }
    }

    fun tagAssignments(id: Int): List<DeckTagAssignmentResponse> = transaction {
        DeckTagAssignmentTable.selectAll().where { DeckTagAssignmentTable.deckId eq id }.map { it.toDeckTagAssignmentResponse() }
    }

    fun tournamentRegistrations(id: Int): List<TournamentRegistrationResponse> = transaction {
        TournamentRegistrationTable.selectAll().where { TournamentRegistrationTable.deckId eq id }.map { it.toTournamentRegistrationResponse() }
    }

    fun articles(id: Int): List<ArticleResponse> = transaction {
        ArticleTable.selectAll().where { ArticleTable.featuredDeckId eq id }.map { it.toArticleResponse() }
    }

}
