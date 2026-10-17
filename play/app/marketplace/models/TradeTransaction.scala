package cards_project.marketplace.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait TradeTransactionStatusType
object TradeTransactionStatusType {
  case object PENDING extends TradeTransactionStatusType
  case object COMPLETED extends TradeTransactionStatusType
  case object DISPUTED extends TradeTransactionStatusType
  case object REFUNDED extends TradeTransactionStatusType
  val values: Seq[TradeTransactionStatusType] = Seq(PENDING, COMPLETED, DISPUTED, REFUNDED)
  def fromString(s: String): TradeTransactionStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TradeTransactionStatusType: $s"))
  implicit val format: Format[TradeTransactionStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class TradeTransaction(
  id: Option[Long] = None,
  finalPrice: BigDecimal,
  platformFee: BigDecimal,
  status: String = "PENDING",
  completedAt: Option[java.time.LocalDateTime] = None,
  listingId: Long,
  buyerId: Long,
  sellerId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object TradeTransaction {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TradeTransaction] = Json.format[TradeTransaction]
}

class TradeTransactionTable(tag: Tag) extends Table[TradeTransaction](tag, "trade_transactions") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def finalPrice = column[BigDecimal]("final_price")
  def platformFee = column[BigDecimal]("platform_fee")
  def status = column[String]("status")
  def completedAt = column[Option[LocalDateTime]]("completed_at")
  def listingId = column[Long]("listing_id")
  // cross-context FK to Player (external context — no local table)
  def buyerId = column[Long]("buyer_id")
  // cross-context FK to Player (external context — no local table)
  def sellerId = column[Long]("seller_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, finalPrice, platformFee, status, completedAt, listingId, buyerId, sellerId, createdAt, updatedAt).mapTo[TradeTransaction]
}

object TradeTransactionRepository {
  val table = TableQuery[TradeTransactionTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[TradeTransaction]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[TradeTransaction]] =
    table.filter(_.id === id).result.headOption

}

case class TradeTransactionAuditLog(
  id: Option[Long] = None,
  recordId: Long,
  field: String,
  oldValue: Option[String] = None,
  newValue: Option[String] = None,
  changedAt: Option[LocalDateTime] = None
)

object TradeTransactionAuditLog {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TradeTransactionAuditLog] = Json.format[TradeTransactionAuditLog]
}

case class TransactionCompleted(
  transactionId: Int,
  buyerId: Int,
  sellerId: Int,
  finalPrice: BigDecimal,
  completedAt: java.time.LocalDateTime
)
object TransactionCompleted {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TransactionCompleted] = Json.format[TransactionCompleted]
}
