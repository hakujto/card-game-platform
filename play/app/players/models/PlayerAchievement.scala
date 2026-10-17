package cards_project.players.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class PlayerAchievement(
  id: Option[Long] = None,
  earnedAt: java.time.LocalDateTime,
  progress: Int = 0,
  isCompleted: Boolean = false,
  playerId: Long,
  achievementId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object PlayerAchievement {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[PlayerAchievement] = Json.format[PlayerAchievement]
}

class PlayerAchievementTable(tag: Tag) extends Table[PlayerAchievement](tag, "player_achievements") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def earnedAt = column[LocalDateTime]("earned_at")
  def progress = column[Int]("progress")
  def isCompleted = column[Boolean]("is_completed")
  def playerId = column[Long]("player_id")
  def achievementId = column[Long]("achievement_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, earnedAt, progress, isCompleted, playerId, achievementId, createdAt, updatedAt).mapTo[PlayerAchievement]
}

object PlayerAchievementRepository {
  val table = TableQuery[PlayerAchievementTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[PlayerAchievement]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[PlayerAchievement]] =
    table.filter(_.id === id).result.headOption

}
