package cards_project.content.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait DraftSessionStatusType
object DraftSessionStatusType {
  case object WAITINGFORPLAYERS extends DraftSessionStatusType
  case object DRAFTING extends DraftSessionStatusType
  case object COMPLETED extends DraftSessionStatusType
  case object ABANDONED extends DraftSessionStatusType
  val values: Seq[DraftSessionStatusType] = Seq(WAITINGFORPLAYERS, DRAFTING, COMPLETED, ABANDONED)
  def fromString(s: String): DraftSessionStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown DraftSessionStatusType: $s"))
  implicit val format: Format[DraftSessionStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait DraftSessionDraftTypeType
object DraftSessionDraftTypeType {
  case object BOOSTER extends DraftSessionDraftTypeType
  case object CUBE extends DraftSessionDraftTypeType
  case object ROCHESTER extends DraftSessionDraftTypeType
  val values: Seq[DraftSessionDraftTypeType] = Seq(BOOSTER, CUBE, ROCHESTER)
  def fromString(s: String): DraftSessionDraftTypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown DraftSessionDraftTypeType: $s"))
  implicit val format: Format[DraftSessionDraftTypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class DraftSession(
  id: Option[Long] = None,
  status: String = "WAITINGFORPLAYERS",
  draftType: String = "BOOSTER",
  packContents: Option[String] = None,
  seats: Int = 8,
  timePerPickSeconds: Int = 30,
  completedAt: Option[java.time.LocalDateTime] = None,
  cardSetId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object DraftSession {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[DraftSession] = Json.format[DraftSession]
}

class DraftSessionTable(tag: Tag) extends Table[DraftSession](tag, "draft_sessions") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def status = column[String]("status")
  def draftType = column[String]("draft_type")
  def packContents = column[Option[String]]("pack_contents")
  def seats = column[Int]("seats")
  def timePerPickSeconds = column[Int]("time_per_pick_seconds")
  def completedAt = column[Option[LocalDateTime]]("completed_at")
  // cross-context FK to CardSet (external context — no local table)
  def cardSetId = column[Long]("card_set_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, status, draftType, packContents, seats, timePerPickSeconds, completedAt, cardSetId, createdAt, updatedAt).mapTo[DraftSession]
}

object DraftSessionRepository {
  val table = TableQuery[DraftSessionTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[DraftSession]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[DraftSession]] =
    table.filter(_.id === id).result.headOption

  def create(item: DraftSession): DBIO[DraftSession] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def updateStatus(id: Long, newStatus: String)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[DraftSession]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(status = newStatus)
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}
