package cards_project.marketplace.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait TradeDisputeStatusType
object TradeDisputeStatusType {
  case object OPEN extends TradeDisputeStatusType
  case object UNDERREVIEW extends TradeDisputeStatusType
  case object RESOLVED extends TradeDisputeStatusType
  case object ESCALATED extends TradeDisputeStatusType
  val values: Seq[TradeDisputeStatusType] = Seq(OPEN, UNDERREVIEW, RESOLVED, ESCALATED)
  def fromString(s: String): TradeDisputeStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TradeDisputeStatusType: $s"))
  implicit val format: Format[TradeDisputeStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait TradeDisputeReasonType
object TradeDisputeReasonType {
  case object ITEMNOTRECEIVED extends TradeDisputeReasonType
  case object ITEMNOTASDESCRIBED extends TradeDisputeReasonType
  case object FRAUDSUSPECTED extends TradeDisputeReasonType
  case object OTHER extends TradeDisputeReasonType
  val values: Seq[TradeDisputeReasonType] = Seq(ITEMNOTRECEIVED, ITEMNOTASDESCRIBED, FRAUDSUSPECTED, OTHER)
  def fromString(s: String): TradeDisputeReasonType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TradeDisputeReasonType: $s"))
  implicit val format: Format[TradeDisputeReasonType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class TradeDispute(
  id: Option[Long] = None,
  status: String = "OPEN",
  reason: String,
  description: String,
  resolution: Option[String] = None,
  openedAt: java.time.LocalDateTime,
  resolvedAt: Option[java.time.LocalDateTime] = None,
  transactionId: Long,
  openedById: Long,
  resolvedById: Option[Long] = None,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object TradeDispute {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TradeDispute] = Json.format[TradeDispute]
}

class TradeDisputeTable(tag: Tag) extends Table[TradeDispute](tag, "trade_disputes") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def status = column[String]("status")
  def reason = column[String]("reason")
  def description = column[String]("description")
  def resolution = column[Option[String]]("resolution")
  def openedAt = column[LocalDateTime]("opened_at")
  def resolvedAt = column[Option[LocalDateTime]]("resolved_at")
  def transactionId = column[Long]("transaction_id")
  // cross-context FK to Player (external context — no local table)
  def openedById = column[Long]("opened_by_id")
  // cross-context FK to Player (external context — no local table)
  def resolvedById = column[Option[Long]]("resolved_by_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, status, reason, description, resolution, openedAt, resolvedAt, transactionId, openedById, resolvedById, createdAt, updatedAt).mapTo[TradeDispute]
}

object TradeDisputeRepository {
  val table = TableQuery[TradeDisputeTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[TradeDispute]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[TradeDispute]] =
    table.filter(_.id === id).result.headOption

  def create(item: TradeDispute): DBIO[TradeDispute] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def updateStatus(id: Long, newStatus: String)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[TradeDispute]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(status = newStatus)
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}
