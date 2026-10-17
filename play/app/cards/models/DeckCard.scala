package cards_project.cards.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class DeckCard(
  id: Option[Long] = None,
  quantity: Int = 1,
  isCommander: Boolean = false,
  deckId: Long,
  cardId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object DeckCard {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[DeckCard] = Json.format[DeckCard]
}

class DeckCardTable(tag: Tag) extends Table[DeckCard](tag, "deck_cards") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def quantity = column[Int]("quantity")
  def isCommander = column[Boolean]("is_commander")
  def deckId = column[Long]("deck_id")
  def cardId = column[Long]("card_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, quantity, isCommander, deckId, cardId, createdAt, updatedAt).mapTo[DeckCard]
}

object DeckCardRepository {
  val table = TableQuery[DeckCardTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[DeckCard]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[DeckCard]] =
    table.filter(_.id === id).result.headOption

  def create(item: DeckCard): DBIO[DeckCard] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: DeckCard)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[DeckCard]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
