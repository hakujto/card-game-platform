package cards_project.cards.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class DeckTag(
  id: Option[Long] = None,
  name: String,
  slug: Option[String] = None,
  color: Option[String] = None,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object DeckTag {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[DeckTag] = Json.format[DeckTag]
}

class DeckTagTable(tag: Tag) extends Table[DeckTag](tag, "deck_tags") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def name = column[String]("name")
  def slug = column[Option[String]]("slug")
  def color = column[Option[String]]("color")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, name, slug, color, createdAt, updatedAt).mapTo[DeckTag]
}

object DeckTagRepository {
  val table = TableQuery[DeckTagTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[DeckTag]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.name.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[DeckTag]] =
    table.filter(_.id === id).result.headOption

  def create(item: DeckTag): DBIO[DeckTag] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: DeckTag)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[DeckTag]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
