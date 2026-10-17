package cards_project.tournaments.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait MatchStatusType
object MatchStatusType {
  case object PENDING extends MatchStatusType
  case object ACTIVE extends MatchStatusType
  case object COMPLETED extends MatchStatusType
  case object BYE extends MatchStatusType
  case object DRAW extends MatchStatusType
  val values: Seq[MatchStatusType] = Seq(PENDING, ACTIVE, COMPLETED, BYE, DRAW)
  def fromString(s: String): MatchStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown MatchStatusType: $s"))
  implicit val format: Format[MatchStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Match(
  id: Option[Long] = None,
  tableNumber: Option[Int] = None,
  status: String = "PENDING",
  player1Wins: Int = 0,
  player2Wins: Int = 0,
  startedAt: Option[java.time.LocalDateTime] = None,
  endedAt: Option[java.time.LocalDateTime] = None,
  resultNotes: Option[String] = None,
  roundId: Long,
  player1Id: Long,
  player2Id: Option[Long] = None,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Match {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Match] = Json.format[Match]
}

class MatchTable(tag: Tag) extends Table[Match](tag, "matches") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def tableNumber = column[Option[Int]]("table_number")
  def status = column[String]("status")
  def player1Wins = column[Int]("player1_wins")
  def player2Wins = column[Int]("player2_wins")
  def startedAt = column[Option[LocalDateTime]]("started_at")
  def endedAt = column[Option[LocalDateTime]]("ended_at")
  def resultNotes = column[Option[String]]("result_notes")
  def roundId = column[Long]("round_id")
  // cross-context FK to Player (external context — no local table)
  def player1Id = column[Long]("player1_id")
  // cross-context FK to Player (external context — no local table)
  def player2Id = column[Option[Long]]("player2_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, tableNumber, status, player1Wins, player2Wins, startedAt, endedAt, resultNotes, roundId, player1Id, player2Id, createdAt, updatedAt).mapTo[Match]
}

object MatchRepository {
  val table = TableQuery[MatchTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Match]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[Match]] =
    table.filter(_.id === id).result.headOption

  def create(item: Match): DBIO[Match] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def updateStatus(id: Long, newStatus: String)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Match]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(status = newStatus)
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}
