package cards_project.marketplace.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class OrderItem(
  id: Option[Long] = None,
  quantity: Int,
  priceAtPurchase: BigDecimal,
  foil: Boolean = false,
  orderId: Long,
  productId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object OrderItem {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[OrderItem] = Json.format[OrderItem]
}

class OrderItemTable(tag: Tag) extends Table[OrderItem](tag, "order_items") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def quantity = column[Int]("quantity")
  def priceAtPurchase = column[BigDecimal]("price_at_purchase")
  def foil = column[Boolean]("foil")
  def orderId = column[Long]("order_id")
  def productId = column[Long]("product_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, quantity, priceAtPurchase, foil, orderId, productId, createdAt, updatedAt).mapTo[OrderItem]
}

object OrderItemRepository {
  val table = TableQuery[OrderItemTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[OrderItem]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[OrderItem]] =
    table.filter(_.id === id).result.headOption

  def create(item: OrderItem): DBIO[OrderItem] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
