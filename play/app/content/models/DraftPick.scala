package cards_project.content.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class DraftPick(
  id: Option[Long] = None,
  pickNumber: Int,
  packNumber: Int,
  pickedAt: java.time.LocalDateTime,
  participantId: Long,
  cardId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object DraftPick {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[DraftPick] = Json.format[DraftPick]
}

class DraftPickTable(tag: Tag) extends Table[DraftPick](tag, "draft_picks") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def pickNumber = column[Int]("pick_number")
  def packNumber = column[Int]("pack_number")
  def pickedAt = column[LocalDateTime]("picked_at")
  def participantId = column[Long]("participant_id")
  // cross-context FK to Card (external context — no local table)
  def cardId = column[Long]("card_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, pickNumber, packNumber, pickedAt, participantId, cardId, createdAt, updatedAt).mapTo[DraftPick]
}

object DraftPickRepository {
  val table = TableQuery[DraftPickTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[DraftPick]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[DraftPick]] =
    table.filter(_.id === id).result.headOption

}
