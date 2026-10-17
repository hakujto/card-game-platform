package cards_project.marketplace.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait TradeListingStatusType
object TradeListingStatusType {
  case object ACTIVE extends TradeListingStatusType
  case object SOLD extends TradeListingStatusType
  case object EXPIRED extends TradeListingStatusType
  case object CANCELLED extends TradeListingStatusType
  case object PENDING extends TradeListingStatusType
  val values: Seq[TradeListingStatusType] = Seq(ACTIVE, SOLD, EXPIRED, CANCELLED, PENDING)
  def fromString(s: String): TradeListingStatusType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TradeListingStatusType: $s"))
  implicit val format: Format[TradeListingStatusType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait TradeListingListingTypeType
object TradeListingListingTypeType {
  case object FIXEDPRICE extends TradeListingListingTypeType
  case object AUCTION extends TradeListingListingTypeType
  case object TRADEOFFER extends TradeListingListingTypeType
  val values: Seq[TradeListingListingTypeType] = Seq(FIXEDPRICE, AUCTION, TRADEOFFER)
  def fromString(s: String): TradeListingListingTypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TradeListingListingTypeType: $s"))
  implicit val format: Format[TradeListingListingTypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait TradeListingConditionType
object TradeListingConditionType {
  case object MINT extends TradeListingConditionType
  case object NEARMINT extends TradeListingConditionType
  case object EXCELLENT extends TradeListingConditionType
  case object GOOD extends TradeListingConditionType
  case object PLAYED extends TradeListingConditionType
  val values: Seq[TradeListingConditionType] = Seq(MINT, NEARMINT, EXCELLENT, GOOD, PLAYED)
  def fromString(s: String): TradeListingConditionType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TradeListingConditionType: $s"))
  implicit val format: Format[TradeListingConditionType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class TradeListing(
  id: Option[Long] = None,
  publicId: String,
  status: String = "ACTIVE",
  listingType: String = "FIXEDPRICE",
  askingPrice: Option[BigDecimal] = None,
  auctionStartPrice: Option[BigDecimal] = None,
  auctionCurrentBid: Option[BigDecimal] = None,
  auctionEndTime: Option[java.time.LocalDateTime] = None,
  foil: Boolean = false,
  condition: String = "MINT",
  quantity: Int = 1,
  description: Option[String] = None,
  expiresAt: Option[java.time.LocalDateTime] = None,
  sellerId: Long,
  cardId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object TradeListing {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TradeListing] = Json.format[TradeListing]
}

class TradeListingTable(tag: Tag) extends Table[TradeListing](tag, "trade_listings") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def publicId = column[String]("public_id", O.Unique)
  def status = column[String]("status")
  def listingType = column[String]("listing_type")
  def askingPrice = column[Option[BigDecimal]]("asking_price")
  def auctionStartPrice = column[Option[BigDecimal]]("auction_start_price")
  def auctionCurrentBid = column[Option[BigDecimal]]("auction_current_bid")
  def auctionEndTime = column[Option[LocalDateTime]]("auction_end_time")
  def foil = column[Boolean]("foil")
  def condition = column[String]("condition")
  def quantity = column[Int]("quantity")
  def description = column[Option[String]]("description")
  def expiresAt = column[Option[LocalDateTime]]("expires_at")
  // cross-context FK to Player (external context — no local table)
  def sellerId = column[Long]("seller_id")
  // cross-context FK to Card (external context — no local table)
  def cardId = column[Long]("card_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, publicId, status, listingType, askingPrice, auctionStartPrice, auctionCurrentBid, auctionEndTime, foil, condition, quantity, description, expiresAt, sellerId, cardId, createdAt, updatedAt).mapTo[TradeListing]
}

object TradeListingRepository {
  val table = TableQuery[TradeListingTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[TradeListing]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.description.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[TradeListing]] =
    table.filter(_.id === id).result.headOption

  def create(item: TradeListing): DBIO[TradeListing] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: TradeListing)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[TradeListing]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def updateStatus(id: Long, newStatus: String)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[TradeListing]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(status = newStatus)
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}
