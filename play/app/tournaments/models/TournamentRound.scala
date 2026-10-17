package cards_project.tournaments.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait TournamentRoundStatusType
object TournamentRoundStatusType {
  case object PENDING extends TournamentRoundStatusType
  case object ACTIVE extends TournamentRoundStatusType
  case object COMPLETED extends TournamentRoundStatusType
  val values: Seq[TournamentRoundStatusType] = Seq(PENDING, ACTIVE, COMPLETED)
  def fromString(s: String): TournamentRoundStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TournamentRoundStatusType: $s"))
  implicit val format: Format[TournamentRoundStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class TournamentRound(
  id: Option[Long] = None,
  roundNumber: Int,
  status: String = "PENDING",
  startedAt: Option[java.time.LocalDateTime] = None,
  endedAt: Option[java.time.LocalDateTime] = None,
  timeLimitMinutes: Int = 50,
  tournamentId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object TournamentRound {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TournamentRound] = Json.format[TournamentRound]
}

class TournamentRoundTable(tag: Tag) extends Table[TournamentRound](tag, "tournament_rounds") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def roundNumber = column[Int]("round_number")
  def status = column[String]("status")
  def startedAt = column[Option[LocalDateTime]]("started_at")
  def endedAt = column[Option[LocalDateTime]]("ended_at")
  def timeLimitMinutes = column[Int]("time_limit_minutes")
  def tournamentId = column[Long]("tournament_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, roundNumber, status, startedAt, endedAt, timeLimitMinutes, tournamentId, createdAt, updatedAt).mapTo[TournamentRound]
}

object TournamentRoundRepository {
  val table = TableQuery[TournamentRoundTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[TournamentRound]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[TournamentRound]] =
    table.filter(_.id === id).result.headOption

  def create(item: TournamentRound): DBIO[TournamentRound] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

}
