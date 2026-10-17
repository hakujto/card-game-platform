package cards_project.cards.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class DeckTagAssignment(
  id: Option[Long] = None,
  deckId: Long,
  tagId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object DeckTagAssignment {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[DeckTagAssignment] = Json.format[DeckTagAssignment]
}

class DeckTagAssignmentTable(tag: Tag) extends Table[DeckTagAssignment](tag, "deck_tag_assignments") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def deckId = column[Long]("deck_id")
  def tagId = column[Long]("tag_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, deckId, tagId, createdAt, updatedAt).mapTo[DeckTagAssignment]
}

object DeckTagAssignmentRepository {
  val table = TableQuery[DeckTagAssignmentTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[DeckTagAssignment]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[DeckTagAssignment]] =
    table.filter(_.id === id).result.headOption

  def create(item: DeckTagAssignment): DBIO[DeckTagAssignment] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
