package cards_project.tournaments.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait TournamentJudgeRoleType
object TournamentJudgeRoleType {
  case object HEADJUDGE extends TournamentJudgeRoleType
  case object JUDGE extends TournamentJudgeRoleType
  case object SCOREKEEPERJUDGE extends TournamentJudgeRoleType
  val values: Seq[TournamentJudgeRoleType] = Seq(HEADJUDGE, JUDGE, SCOREKEEPERJUDGE)
  def fromString(s: String): TournamentJudgeRoleType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TournamentJudgeRoleType: $s"))
  implicit val format: Format[TournamentJudgeRoleType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class TournamentJudge(
  id: Option[Long] = None,
  role: String = "JUDGE",
  tournamentId: Long,
  playerId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object TournamentJudge {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TournamentJudge] = Json.format[TournamentJudge]
}

class TournamentJudgeTable(tag: Tag) extends Table[TournamentJudge](tag, "tournament_judges") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def role = column[String]("role")
  def tournamentId = column[Long]("tournament_id")
  // cross-context FK to Player (external context — no local table)
  def playerId = column[Long]("player_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, role, tournamentId, playerId, createdAt, updatedAt).mapTo[TournamentJudge]
}

object TournamentJudgeRepository {
  val table = TableQuery[TournamentJudgeTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[TournamentJudge]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[TournamentJudge]] =
    table.filter(_.id === id).result.headOption

  def create(item: TournamentJudge): DBIO[TournamentJudge] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
