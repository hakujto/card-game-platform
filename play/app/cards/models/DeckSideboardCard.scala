package cards_project.cards.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class DeckSideboardCard(
  id: Option[Long] = None,
  quantity: Int = 1,
  deckId: Long,
  cardId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object DeckSideboardCard {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[DeckSideboardCard] = Json.format[DeckSideboardCard]
}

class DeckSideboardCardTable(tag: Tag) extends Table[DeckSideboardCard](tag, "deck_sideboard_cards") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def quantity = column[Int]("quantity")
  def deckId = column[Long]("deck_id")
  def cardId = column[Long]("card_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, quantity, deckId, cardId, createdAt, updatedAt).mapTo[DeckSideboardCard]
}

object DeckSideboardCardRepository {
  val table = TableQuery[DeckSideboardCardTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[DeckSideboardCard]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[DeckSideboardCard]] =
    table.filter(_.id === id).result.headOption

  def create(item: DeckSideboardCard): DBIO[DeckSideboardCard] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: DeckSideboardCard)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[DeckSideboardCard]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
