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

import cards_project.players.model.CraftingRecipeTable
import cards_project.cards.model.CardTable

object CraftingIngredientTable : IntIdTable("crafting_ingredient") {
    val quantity = integer("quantity")
    val recipeId = reference("recipe_id", CraftingRecipeTable)
    val cardId = reference("card_id", CardTable)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class CraftingIngredientRequest(
    val quantity: Int,
    val recipeId: Int,
    val cardId: Int
)

data class CraftingIngredientResponse(
    val id: Int,
    val quantity: Int,
    val recipeId: Int,
    val cardId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toCraftingIngredientResponse() = CraftingIngredientResponse(
    id = this[CraftingIngredientTable.id].value,
    quantity = this[CraftingIngredientTable.quantity],
    recipeId = this[CraftingIngredientTable.recipeId].value,
    cardId = this[CraftingIngredientTable.cardId].value,
    createdAt = this[CraftingIngredientTable.createdAt].toString(),
    updatedAt = this[CraftingIngredientTable.updatedAt].toString()
)

object CraftingIngredientRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<CraftingIngredientResponse> = transaction {
        CraftingIngredientTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toCraftingIngredientResponse() }
    }

    fun findById(id: Int): CraftingIngredientResponse? = transaction {
        CraftingIngredientTable.selectAll().where { CraftingIngredientTable.id eq id }.singleOrNull()?.toCraftingIngredientResponse()
    }

    fun create(req: CraftingIngredientRequest): CraftingIngredientResponse = transaction {
        val inserted = CraftingIngredientTable.insertAndGetId {
            it[quantity] = req.quantity
            it[recipeId] = EntityID(req.recipeId, CraftingRecipeTable)
            it[cardId] = EntityID(req.cardId, CardTable)
        }
        CraftingIngredientTable.selectAll().where { CraftingIngredientTable.id eq inserted }.single().toCraftingIngredientResponse()
    }

    fun delete(id: Int): Boolean = transaction {
        CraftingIngredientTable.deleteWhere { CraftingIngredientTable.id eq id } > 0
    }

}
