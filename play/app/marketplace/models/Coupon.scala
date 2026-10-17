package cards_project.marketplace.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait CouponDiscountTypeType
object CouponDiscountTypeType {
  case object PERCENT extends CouponDiscountTypeType
  case object FIXED extends CouponDiscountTypeType
  val values: Seq[CouponDiscountTypeType] = Seq(PERCENT, FIXED)
  def fromString(s: String): CouponDiscountTypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown CouponDiscountTypeType: $s"))
  implicit val format: Format[CouponDiscountTypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Coupon(
  id: Option[Long] = None,
  code: String,
  discountType: String = "PERCENT",
  discountValue: BigDecimal,
  minOrderValue: BigDecimal = 0,
  validFrom: java.time.LocalDateTime,
  validUntil: java.time.LocalDateTime,
  isActive: Boolean = true,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Coupon {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Coupon] = Json.format[Coupon]
}

class CouponTable(tag: Tag) extends Table[Coupon](tag, "coupons") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def code = column[String]("code", O.Unique)
  def discountType = column[String]("discount_type")
  def discountValue = column[BigDecimal]("discount_value")
  def minOrderValue = column[BigDecimal]("min_order_value")
  def maxUses = column[Option[Int]]("max_uses")
  def usesCount = column[Int]("uses_count")
  def validFrom = column[LocalDateTime]("valid_from")
  def validUntil = column[LocalDateTime]("valid_until")
  def isActive = column[Boolean]("is_active")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, code, discountType, discountValue, minOrderValue, validFrom, validUntil, isActive, createdAt, updatedAt).mapTo[Coupon]
}

object CouponRepository {
  val table = TableQuery[CouponTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Coupon]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.code.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[Coupon]] =
    table.filter(_.id === id).result.headOption

  def create(item: Coupon): DBIO[Coupon] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: Coupon)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Coupon]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

}
