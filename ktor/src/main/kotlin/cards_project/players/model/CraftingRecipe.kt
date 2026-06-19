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

import cards_project.cards.model.*

object CraftingRecipeTable : IntIdTable("crafting_recipe") {
    val dustCost = integer("dust_cost")
    val isAvailable = bool("is_available").default(true)
    val resultCardId = reference("result_card_id", CardTable, onDelete = ReferenceOption.RESTRICT)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class CraftingRecipeRequest(
    val dustCost: Int,
    val isAvailable: Boolean,
    val resultCardId: Int
)

data class CraftingRecipeResponse(
    val id: Int,
    val dustCost: Int,
    val isAvailable: Boolean,
    val resultCardId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toCraftingRecipeResponse() = CraftingRecipeResponse(
    id = this[CraftingRecipeTable.id].value,
    dustCost = this[CraftingRecipeTable.dustCost],
    isAvailable = this[CraftingRecipeTable.isAvailable],
    resultCardId = this[CraftingRecipeTable.resultCardId].value,
    createdAt = this[CraftingRecipeTable.createdAt].toString(),
    updatedAt = this[CraftingRecipeTable.updatedAt].toString()
)

object CraftingRecipeRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<CraftingRecipeResponse> = transaction {
        CraftingRecipeTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toCraftingRecipeResponse() }
    }

    fun findById(id: Int): CraftingRecipeResponse? = transaction {
        CraftingRecipeTable.selectAll().where { CraftingRecipeTable.id eq id }.singleOrNull()?.toCraftingRecipeResponse()
    }

    fun create(req: CraftingRecipeRequest): CraftingRecipeResponse = transaction {
        val inserted = CraftingRecipeTable.insertAndGetId {
            it[dustCost] = req.dustCost
            it[isAvailable] = req.isAvailable
            it[resultCardId] = EntityID(req.resultCardId, CardTable)
        }
        CraftingRecipeTable.selectAll().where { CraftingRecipeTable.id eq inserted }.single().toCraftingRecipeResponse()
    }

    fun update(id: Int, req: CraftingRecipeRequest): CraftingRecipeResponse? = transaction {
        val updated = CraftingRecipeTable.update({ CraftingRecipeTable.id eq id }) {
            it[dustCost] = req.dustCost
            it[isAvailable] = req.isAvailable
            it[resultCardId] = EntityID(req.resultCardId, CardTable)
        }
        if (updated == 0) return@transaction null
        CraftingRecipeTable.selectAll().where { CraftingRecipeTable.id eq id }.singleOrNull()?.toCraftingRecipeResponse()
    }

    fun ingredients(id: Int): List<CraftingIngredientResponse> = transaction {
        CraftingIngredientTable.selectAll().where { CraftingIngredientTable.recipeId eq id }.map { it.toCraftingIngredientResponse() }
    }

}
