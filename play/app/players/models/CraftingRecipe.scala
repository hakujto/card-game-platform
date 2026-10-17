package cards_project.players.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class CraftingRecipe(
  id: Option[Long] = None,
  dustCost: Int,
  isAvailable: Boolean = true,
  resultCardId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object CraftingRecipe {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[CraftingRecipe] = Json.format[CraftingRecipe]
}

class CraftingRecipeTable(tag: Tag) extends Table[CraftingRecipe](tag, "crafting_recipes") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def dustCost = column[Int]("dust_cost")
  def isAvailable = column[Boolean]("is_available")
  // cross-context FK to Card (external context — no local table)
  def resultCardId = column[Long]("result_card_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, dustCost, isAvailable, resultCardId, createdAt, updatedAt).mapTo[CraftingRecipe]
}

object CraftingRecipeRepository {
  val table = TableQuery[CraftingRecipeTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[CraftingRecipe]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[CraftingRecipe]] =
    table.filter(_.id === id).result.headOption

  def create(item: CraftingRecipe): DBIO[CraftingRecipe] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: CraftingRecipe)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[CraftingRecipe]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

}
