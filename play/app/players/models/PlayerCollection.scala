package cards_project.players.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait PlayerCollectionConditionType
object PlayerCollectionConditionType {
  case object MINT extends PlayerCollectionConditionType
  case object NEARMINT extends PlayerCollectionConditionType
  case object EXCELLENT extends PlayerCollectionConditionType
  case object GOOD extends PlayerCollectionConditionType
  case object PLAYED extends PlayerCollectionConditionType
  val values: Seq[PlayerCollectionConditionType] = Seq(MINT, NEARMINT, EXCELLENT, GOOD, PLAYED)
  def fromString(s: String): PlayerCollectionConditionType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown PlayerCollectionConditionType: $s"))
  implicit val format: Format[PlayerCollectionConditionType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait PlayerCollectionAcquiredViaType
object PlayerCollectionAcquiredViaType {
  case object PURCHASE extends PlayerCollectionAcquiredViaType
  case object TRADE extends PlayerCollectionAcquiredViaType
  case object TOURNAMENTREWARD extends PlayerCollectionAcquiredViaType
  case object PACK extends PlayerCollectionAcquiredViaType
  case object CRAFT extends PlayerCollectionAcquiredViaType
  val values: Seq[PlayerCollectionAcquiredViaType] = Seq(PURCHASE, TRADE, TOURNAMENTREWARD, PACK, CRAFT)
  def fromString(s: String): PlayerCollectionAcquiredViaType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown PlayerCollectionAcquiredViaType: $s"))
  implicit val format: Format[PlayerCollectionAcquiredViaType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class PlayerCollection(
  id: Option[Long] = None,
  quantity: Int = 1,
  foil: Boolean = false,
  condition: String = "MINT",
  acquiredAt: java.time.LocalDateTime,
  acquiredVia: String = "PURCHASE",
  playerId: Long,
  cardId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object PlayerCollection {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[PlayerCollection] = Json.format[PlayerCollection]
}

class PlayerCollectionTable(tag: Tag) extends Table[PlayerCollection](tag, "player_collections") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def quantity = column[Int]("quantity")
  def foil = column[Boolean]("foil")
  def condition = column[String]("condition")
  def acquiredAt = column[LocalDateTime]("acquired_at")
  def acquiredVia = column[String]("acquired_via")
  def playerId = column[Long]("player_id")
  // cross-context FK to Card (external context — no local table)
  def cardId = column[Long]("card_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, quantity, foil, condition, acquiredAt, acquiredVia, playerId, cardId, createdAt, updatedAt).mapTo[PlayerCollection]
}

object PlayerCollectionRepository {
  val table = TableQuery[PlayerCollectionTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[PlayerCollection]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[PlayerCollection]] =
    table.filter(_.id === id).result.headOption

  def create(item: PlayerCollection): DBIO[PlayerCollection] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: PlayerCollection)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[PlayerCollection]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
