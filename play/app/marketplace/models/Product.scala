package cards_project.marketplace.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait ProductProductTypeType
object ProductProductTypeType {
  case object SINGLECARD extends ProductProductTypeType
  case object BOOSTERPACK extends ProductProductTypeType
  case object BUNDLE extends ProductProductTypeType
  case object PRECONSTRUCTEDDECK extends ProductProductTypeType
  case object ACCESSORY extends ProductProductTypeType
  val values: Seq[ProductProductTypeType] = Seq(SINGLECARD, BOOSTERPACK, BUNDLE, PRECONSTRUCTEDDECK, ACCESSORY)
  def fromString(s: String): ProductProductTypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown ProductProductTypeType: $s"))
  implicit val format: Format[ProductProductTypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Product(
  id: Option[Long] = None,
  name: String,
  productType: String = "SINGLECARD",
  price: BigDecimal,
  stock: Int = 0,
  active: Boolean = true,
  discountPercent: Int = 0,
  description: Option[String] = None,
  imageUrl: Option[String] = None,
  featured: Boolean = false,
  cardId: Option[Long] = None,
  cardSetId: Option[Long] = None,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Product {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Product] = Json.format[Product]
}

class ProductTable(tag: Tag) extends Table[Product](tag, "products") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def name = column[String]("name")
  def productType = column[String]("product_type")
  def price = column[BigDecimal]("price")
  def stock = column[Int]("stock")
  def active = column[Boolean]("active")
  def discountPercent = column[Int]("discount_percent")
  def description = column[Option[String]]("description")
  def imageUrl = column[Option[String]]("image_url")
  def featured = column[Boolean]("featured")
  // cross-context FK to Card (external context — no local table)
  def cardId = column[Option[Long]]("card_id")
  // cross-context FK to CardSet (external context — no local table)
  def cardSetId = column[Option[Long]]("card_set_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, name, productType, price, stock, active, discountPercent, description, imageUrl, featured, cardId, cardSetId, createdAt, updatedAt).mapTo[Product]
}

object ProductRepository {
  val table = TableQuery[ProductTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Product]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.name.like("%" + query + "%") || row.description.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[Product]] =
    table.filter(_.id === id).result.headOption

  def create(item: Product): DBIO[Product] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: Product)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Product]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def patch(id: Long, fields: Map[String, JsValue])(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Product]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(
          description = fields.get("description").flatMap(_.asOpt[String]).orElse(existing.description),
          featured = fields.get("featured").flatMap(_.asOpt[Boolean]).getOrElse(existing.featured)
        )
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}
