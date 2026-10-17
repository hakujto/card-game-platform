package cards_project.tournaments.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait TournamentStatusType
object TournamentStatusType {
  case object DRAFT extends TournamentStatusType
  case object REGISTRATION extends TournamentStatusType
  case object ONGOING extends TournamentStatusType
  case object COMPLETED extends TournamentStatusType
  case object CANCELLED extends TournamentStatusType
  val values: Seq[TournamentStatusType] = Seq(DRAFT, REGISTRATION, ONGOING, COMPLETED, CANCELLED)
  def fromString(s: String): TournamentStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TournamentStatusType: $s"))
  implicit val format: Format[TournamentStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait TournamentFormatType
object TournamentFormatType {
  case object STANDARD extends TournamentFormatType
  case object EXTENDED extends TournamentFormatType
  case object LEGACY extends TournamentFormatType
  case object VINTAGE extends TournamentFormatType
  case object COMMANDER extends TournamentFormatType
  case object DRAFT extends TournamentFormatType
  val values: Seq[TournamentFormatType] = Seq(STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT)
  def fromString(s: String): TournamentFormatType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TournamentFormatType: $s"))
  implicit val format: Format[TournamentFormatType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait TournamentTournamentTypeType
object TournamentTournamentTypeType {
  case object SWISS extends TournamentTournamentTypeType
  case object SINGLEELIMINATION extends TournamentTournamentTypeType
  case object DOUBLEELIMINATION extends TournamentTournamentTypeType
  case object ROUNDROBIN extends TournamentTournamentTypeType
  val values: Seq[TournamentTournamentTypeType] = Seq(SWISS, SINGLEELIMINATION, DOUBLEELIMINATION, ROUNDROBIN)
  def fromString(s: String): TournamentTournamentTypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TournamentTournamentTypeType: $s"))
  implicit val format: Format[TournamentTournamentTypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Tournament(
  id: Option[Long] = None,
  publicId: String,
  name: String,
  description: Option[String] = None,
  status: String = "DRAFT",
  bracketData: Option[String] = None,
  format: String = "STANDARD",
  tournamentType: String = "SWISS",
  maxPlayers: Int,
  entryFee: BigDecimal = 0,
  prizePool: BigDecimal = 0,
  startTime: java.time.LocalDateTime,
  endTime: Option[java.time.LocalDateTime] = None,
  isOnline: Boolean = true,
  location: Option[String] = None,
  rulesText: Option[String] = None,
  seasonId: Long,
  organizerId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Tournament {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Tournament] = Json.format[Tournament]
}

class TournamentTable(tag: Tag) extends Table[Tournament](tag, "tournaments") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def publicId = column[String]("public_id", O.Unique)
  def name = column[String]("name")
  def description = column[Option[String]]("description")
  def status = column[String]("status")
  def bracketData = column[Option[String]]("bracket_data")
  def format = column[String]("format")
  def tournamentType = column[String]("tournament_type")
  def maxPlayers = column[Int]("max_players")
  def entryFee = column[BigDecimal]("entry_fee")
  def prizePool = column[BigDecimal]("prize_pool")
  def startTime = column[LocalDateTime]("start_time")
  def endTime = column[Option[LocalDateTime]]("end_time")
  def isOnline = column[Boolean]("is_online")
  def location = column[Option[String]]("location")
  def rulesText = column[Option[String]]("rules_text")
  def seasonId = column[Long]("season_id")
  // cross-context FK to Player (external context — no local table)
  def organizerId = column[Long]("organizer_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, publicId, name, description, status, bracketData, format, tournamentType, maxPlayers, entryFee, prizePool, startTime, endTime, isOnline, location, rulesText, seasonId, organizerId, createdAt, updatedAt).mapTo[Tournament]
}

object TournamentRepository {
  val table = TableQuery[TournamentTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Tournament]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.name.like("%" + query + "%") || row.description.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[Tournament]] =
    table.filter(_.id === id).result.headOption

  def create(item: Tournament): DBIO[Tournament] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: Tournament)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Tournament]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def patch(id: Long, fields: Map[String, JsValue])(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Tournament]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(
          description = fields.get("description").flatMap(_.asOpt[String]).orElse(existing.description),
          location = fields.get("location").flatMap(_.asOpt[String]).orElse(existing.location),
          rulesText = fields.get("rules_text").flatMap(_.asOpt[String]).orElse(existing.rulesText)
        )
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

  def updateStatus(id: Long, newStatus: String)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Tournament]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(status = newStatus)
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}

case class TournamentAuditLog(
  id: Option[Long] = None,
  recordId: Long,
  field: String,
  oldValue: Option[String] = None,
  newValue: Option[String] = None,
  changedAt: Option[LocalDateTime] = None
)

object TournamentAuditLog {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TournamentAuditLog] = Json.format[TournamentAuditLog]
}

case class TournamentCompleted(
  tournamentId: Int,
  seasonId: Int,
  completedAt: java.time.LocalDateTime
)
object TournamentCompleted {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TournamentCompleted] = Json.format[TournamentCompleted]
}

case class PlayerRegistered(
  tournamentId: Int,
  playerId: Int,
  registeredAt: java.time.LocalDateTime
)
object PlayerRegistered {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[PlayerRegistered] = Json.format[PlayerRegistered]
}
