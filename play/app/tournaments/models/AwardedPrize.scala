package cards_project.tournaments.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class AwardedPrize(
  id: Option[Long] = None,
  finalPlacement: Int,
  awardedAt: java.time.LocalDateTime,
  claimed: Boolean = false,
  claimedAt: Option[java.time.LocalDateTime] = None,
  prizeId: Long,
  playerId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object AwardedPrize {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[AwardedPrize] = Json.format[AwardedPrize]
}

class AwardedPrizeTable(tag: Tag) extends Table[AwardedPrize](tag, "awarded_prizes") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def finalPlacement = column[Int]("final_placement")
  def awardedAt = column[LocalDateTime]("awarded_at")
  def claimed = column[Boolean]("claimed")
  def claimedAt = column[Option[LocalDateTime]]("claimed_at")
  def prizeId = column[Long]("prize_id")
  // cross-context FK to Player (external context — no local table)
  def playerId = column[Long]("player_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, finalPlacement, awardedAt, claimed, claimedAt, prizeId, playerId, createdAt, updatedAt).mapTo[AwardedPrize]
}

object AwardedPrizeRepository {
  val table = TableQuery[AwardedPrizeTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[AwardedPrize]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[AwardedPrize]] =
    table.filter(_.id === id).result.headOption

}
