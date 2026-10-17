package cards_project.tournaments.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait GameWinnerSideType
object GameWinnerSideType {
  case object PLAYER1 extends GameWinnerSideType
  case object PLAYER2 extends GameWinnerSideType
  case object DRAW extends GameWinnerSideType
  val values: Seq[GameWinnerSideType] = Seq(PLAYER1, PLAYER2, DRAW)
  def fromString(s: String): GameWinnerSideType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown GameWinnerSideType: $s"))
  implicit val format: Format[GameWinnerSideType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait GameEndedByType
object GameEndedByType {
  case object NORMAL extends GameEndedByType
  case object TIMEOUT extends GameEndedByType
  case object CONCESSION extends GameEndedByType
  case object DRAWOFFER extends GameEndedByType
  val values: Seq[GameEndedByType] = Seq(NORMAL, TIMEOUT, CONCESSION, DRAWOFFER)
  def fromString(s: String): GameEndedByType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown GameEndedByType: $s"))
  implicit val format: Format[GameEndedByType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Game(
  id: Option[Long] = None,
  gameNumber: Int,
  winnerSide: Option[String] = None,
  complexityScore: Option[Double] = None,
  turnsPlayed: Option[Int] = None,
  durationSeconds: Option[Int] = None,
  endedBy: Option[String] = None,
  replayUrl: Option[String] = None,
  matchId: Long,
  winnerId: Option[Long] = None,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Game {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Game] = Json.format[Game]
}

class GameTable(tag: Tag) extends Table[Game](tag, "games") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def gameNumber = column[Int]("game_number")
  def winnerSide = column[Option[String]]("winner_side")
  def complexityScore = column[Option[Double]]("complexity_score")
  def turnsPlayed = column[Option[Int]]("turns_played")
  def durationSeconds = column[Option[Int]]("duration_seconds")
  def endedBy = column[Option[String]]("ended_by")
  def replayUrl = column[Option[String]]("replay_url")
  def matchId = column[Long]("match_id")
  // cross-context FK to Player (external context — no local table)
  def winnerId = column[Option[Long]]("winner_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, gameNumber, winnerSide, complexityScore, turnsPlayed, durationSeconds, endedBy, replayUrl, matchId, winnerId, createdAt, updatedAt).mapTo[Game]
}

object GameRepository {
  val table = TableQuery[GameTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Game]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[Game]] =
    table.filter(_.id === id).result.headOption

  def create(item: Game): DBIO[Game] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

}
