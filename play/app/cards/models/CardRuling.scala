package cards_project.cards.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class CardRuling(
  id: Option[Long] = None,
  rulingText: String,
  publishedAt: java.time.LocalDate,
  source: String,
  cardId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object CardRuling {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[CardRuling] = Json.format[CardRuling]
}

class CardRulingTable(tag: Tag) extends Table[CardRuling](tag, "card_rulings") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def rulingText = column[String]("ruling_text")
  def publishedAt = column[LocalDate]("published_at")
  def source = column[String]("source")
  def cardId = column[Long]("card_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, rulingText, publishedAt, source, cardId, createdAt, updatedAt).mapTo[CardRuling]
}

object CardRulingRepository {
  val table = TableQuery[CardRulingTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[CardRuling]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[CardRuling]] =
    table.filter(_.id === id).result.headOption

  def create(item: CardRuling): DBIO[CardRuling] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
