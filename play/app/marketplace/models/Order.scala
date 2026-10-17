package cards_project.marketplace.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait OrderStatusType
object OrderStatusType {
  case object PENDING extends OrderStatusType
  case object PAID extends OrderStatusType
  case object PROCESSING extends OrderStatusType
  case object SHIPPED extends OrderStatusType
  case object COMPLETED extends OrderStatusType
  case object CANCELLED extends OrderStatusType
  case object REFUNDED extends OrderStatusType
  val values: Seq[OrderStatusType] = Seq(PENDING, PAID, PROCESSING, SHIPPED, COMPLETED, CANCELLED, REFUNDED)
  def fromString(s: String): OrderStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown OrderStatusType: $s"))
  implicit val format: Format[OrderStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait OrderPaymentMethodType
object OrderPaymentMethodType {
  case object CARD extends OrderPaymentMethodType
  case object PAYPAL extends OrderPaymentMethodType
  case object CRYPTO extends OrderPaymentMethodType
  case object PLATFORMCREDITS extends OrderPaymentMethodType
  val values: Seq[OrderPaymentMethodType] = Seq(CARD, PAYPAL, CRYPTO, PLATFORMCREDITS)
  def fromString(s: String): OrderPaymentMethodType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown OrderPaymentMethodType: $s"))
  implicit val format: Format[OrderPaymentMethodType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Order(
  id: Option[Long] = None,
  status: String = "PENDING",
  total: BigDecimal = 0,
  discountApplied: BigDecimal = 0,
  currency: String = "USD",
  paymentMethod: Option[String] = None,
  shippingAddress: Option[String] = None,
  trackingNumber: Option[String] = None,
  paidAt: Option[java.time.LocalDateTime] = None,
  shippedAt: Option[java.time.LocalDateTime] = None,
  playerId: Long,
  couponId: Option[Long] = None,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Order {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Order] = Json.format[Order]
}

class OrderTable(tag: Tag) extends Table[Order](tag, "orders") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def status = column[String]("status")
  def total = column[BigDecimal]("total")
  def discountApplied = column[BigDecimal]("discount_applied")
  def currency = column[String]("currency")
  def paymentMethod = column[Option[String]]("payment_method")
  def paymentReference = column[Option[String]]("payment_reference")
  def shippingAddress = column[Option[String]]("shipping_address")
  def trackingNumber = column[Option[String]]("tracking_number")
  def paidAt = column[Option[LocalDateTime]]("paid_at")
  def shippedAt = column[Option[LocalDateTime]]("shipped_at")
  // cross-context FK to Player (external context — no local table)
  def playerId = column[Long]("player_id")
  def couponId = column[Option[Long]]("coupon_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, status, total, discountApplied, currency, paymentMethod, shippingAddress, trackingNumber, paidAt, shippedAt, playerId, couponId, createdAt, updatedAt).mapTo[Order]
}

object OrderRepository {
  val table = TableQuery[OrderTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Order]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[Order]] =
    table.filter(_.id === id).result.headOption

  def create(item: Order): DBIO[Order] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def updateStatus(id: Long, newStatus: String)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Order]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(status = newStatus)
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}

case class OrderAuditLog(
  id: Option[Long] = None,
  recordId: Long,
  field: String,
  oldValue: Option[String] = None,
  newValue: Option[String] = None,
  changedAt: Option[LocalDateTime] = None
)

object OrderAuditLog {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[OrderAuditLog] = Json.format[OrderAuditLog]
}

case class OrderPaid(
  orderId: Int,
  playerId: Int,
  total: BigDecimal,
  paymentMethod: String,
  paidAt: java.time.LocalDateTime
)
object OrderPaid {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[OrderPaid] = Json.format[OrderPaid]
}

case class OrderShipped(
  orderId: Int,
  trackingNumber: String,
  shippedAt: java.time.LocalDateTime
)
object OrderShipped {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[OrderShipped] = Json.format[OrderShipped]
}

case class OrderRefunded(
  orderId: Int,
  refundedAt: java.time.LocalDateTime
)
object OrderRefunded {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[OrderRefunded] = Json.format[OrderRefunded]
}
