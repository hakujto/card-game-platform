package cards_project.content.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class DraftParticipant(
  id: Option[Long] = None,
  seatNumber: Int,
  joinedAt: java.time.LocalDateTime,
  sessionId: Long,
  playerId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object DraftParticipant {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[DraftParticipant] = Json.format[DraftParticipant]
}

class DraftParticipantTable(tag: Tag) extends Table[DraftParticipant](tag, "draft_participants") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def seatNumber = column[Int]("seat_number")
  def joinedAt = column[LocalDateTime]("joined_at")
  def sessionId = column[Long]("session_id")
  // cross-context FK to Player (external context — no local table)
  def playerId = column[Long]("player_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, seatNumber, joinedAt, sessionId, playerId, createdAt, updatedAt).mapTo[DraftParticipant]
}

object DraftParticipantRepository {
  val table = TableQuery[DraftParticipantTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[DraftParticipant]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[DraftParticipant]] =
    table.filter(_.id === id).result.headOption

  def create(item: DraftParticipant): DBIO[DraftParticipant] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

}
