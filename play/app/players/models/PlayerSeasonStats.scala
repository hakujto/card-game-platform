package cards_project.players.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait PlayerSeasonStatsHighestRankType
object PlayerSeasonStatsHighestRankType {
  case object BRONZE extends PlayerSeasonStatsHighestRankType
  case object SILVER extends PlayerSeasonStatsHighestRankType
  case object GOLD extends PlayerSeasonStatsHighestRankType
  case object PLATINUM extends PlayerSeasonStatsHighestRankType
  case object DIAMOND extends PlayerSeasonStatsHighestRankType
  case object MASTER extends PlayerSeasonStatsHighestRankType
  case object GRANDMASTER extends PlayerSeasonStatsHighestRankType
  val values: Seq[PlayerSeasonStatsHighestRankType] = Seq(BRONZE, SILVER, GOLD, PLATINUM, DIAMOND, MASTER, GRANDMASTER)
  def fromString(s: String): PlayerSeasonStatsHighestRankType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown PlayerSeasonStatsHighestRankType: $s"))
  implicit val format: Format[PlayerSeasonStatsHighestRankType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class PlayerSeasonStats(
  id: Option[Long] = None,
  wins: Int = 0,
  losses: Int = 0,
  draws: Int = 0,
  tournamentWins: Int = 0,
  highestRank: Option[String] = None,
  seasonPoints: Int = 0,
  playerId: Long,
  seasonId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object PlayerSeasonStats {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[PlayerSeasonStats] = Json.format[PlayerSeasonStats]
}

class PlayerSeasonStatsTable(tag: Tag) extends Table[PlayerSeasonStats](tag, "player_season_statses") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def wins = column[Int]("wins")
  def losses = column[Int]("losses")
  def draws = column[Int]("draws")
  def tournamentWins = column[Int]("tournament_wins")
  def highestRank = column[Option[String]]("highest_rank")
  def seasonPoints = column[Int]("season_points")
  def playerId = column[Long]("player_id")
  // cross-context FK to Season (external context — no local table)
  def seasonId = column[Long]("season_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, wins, losses, draws, tournamentWins, highestRank, seasonPoints, playerId, seasonId, createdAt, updatedAt).mapTo[PlayerSeasonStats]
}

object PlayerSeasonStatsRepository {
  val table = TableQuery[PlayerSeasonStatsTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[PlayerSeasonStats]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[PlayerSeasonStats]] =
    table.filter(_.id === id).result.headOption

}
