package cards_project.players.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class CraftingIngredient(
  id: Option[Long] = None,
  quantity: Int = 1,
  recipeId: Long,
  cardId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object CraftingIngredient {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[CraftingIngredient] = Json.format[CraftingIngredient]
}

class CraftingIngredientTable(tag: Tag) extends Table[CraftingIngredient](tag, "crafting_ingredients") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def quantity = column[Int]("quantity")
  def recipeId = column[Long]("recipe_id")
  // cross-context FK to Card (external context — no local table)
  def cardId = column[Long]("card_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, quantity, recipeId, cardId, createdAt, updatedAt).mapTo[CraftingIngredient]
}

object CraftingIngredientRepository {
  val table = TableQuery[CraftingIngredientTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[CraftingIngredient]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[CraftingIngredient]] =
    table.filter(_.id === id).result.headOption

  def create(item: CraftingIngredient): DBIO[CraftingIngredient] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
