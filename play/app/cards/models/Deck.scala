package cards_project.cards.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait DeckFormatType
object DeckFormatType {
  case object STANDARD extends DeckFormatType
  case object EXTENDED extends DeckFormatType
  case object LEGACY extends DeckFormatType
  case object VINTAGE extends DeckFormatType
  case object COMMANDER extends DeckFormatType
  case object DRAFT extends DeckFormatType
  val values: Seq[DeckFormatType] = Seq(STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT)
  def fromString(s: String): DeckFormatType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown DeckFormatType: $s"))
  implicit val format: Format[DeckFormatType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait DeckArchetypeType
object DeckArchetypeType {
  case object AGGRO extends DeckArchetypeType
  case object CONTROL extends DeckArchetypeType
  case object MIDRANGE extends DeckArchetypeType
  case object COMBO extends DeckArchetypeType
  case object PRISON extends DeckArchetypeType
  case object TEMPO extends DeckArchetypeType
  val values: Seq[DeckArchetypeType] = Seq(AGGRO, CONTROL, MIDRANGE, COMBO, PRISON, TEMPO)
  def fromString(s: String): DeckArchetypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown DeckArchetypeType: $s"))
  implicit val format: Format[DeckArchetypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Deck(
  id: Option[Long] = None,
  name: String,
  description: Option[String] = None,
  format: String = "STANDARD",
  isPublic: Boolean = false,
  isTournamentLegal: Boolean = false,
  archetype: Option[String] = None,
  wins: Int = 0,
  losses: Int = 0,
  draws: Int = 0,
  playerId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Deck {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Deck] = Json.format[Deck]
}

class DeckTable(tag: Tag) extends Table[Deck](tag, "decks") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def name = column[String]("name")
  def description = column[Option[String]]("description")
  def format = column[String]("format")
  def isPublic = column[Boolean]("is_public")
  def isTournamentLegal = column[Boolean]("is_tournament_legal")
  def archetype = column[Option[String]]("archetype")
  def wins = column[Int]("wins")
  def losses = column[Int]("losses")
  def draws = column[Int]("draws")
  // cross-context FK to Player (external context — no local table)
  def playerId = column[Long]("player_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, name, description, format, isPublic, isTournamentLegal, archetype, wins, losses, draws, playerId, createdAt, updatedAt).mapTo[Deck]
}

object DeckRepository {
  val table = TableQuery[DeckTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Deck]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.name.like("%" + query + "%") || row.description.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[Deck]] =
    table.filter(_.id === id).result.headOption

  def create(item: Deck): DBIO[Deck] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: Deck)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Deck]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def patch(id: Long, fields: Map[String, JsValue])(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Deck]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(
          name = fields.get("name").flatMap(_.asOpt[String]).getOrElse(existing.name),
          description = fields.get("description").flatMap(_.asOpt[String]).orElse(existing.description),
          archetype = fields.get("archetype").flatMap(_.asOpt[String]).orElse(existing.archetype)
        )
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
