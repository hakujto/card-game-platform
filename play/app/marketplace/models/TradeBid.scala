package cards_project.marketplace.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class TradeBid(
  id: Option[Long] = None,
  amount: BigDecimal,
  placedAt: java.time.LocalDateTime,
  isWinning: Boolean = false,
  listingId: Long,
  bidderId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object TradeBid {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TradeBid] = Json.format[TradeBid]
}

class TradeBidTable(tag: Tag) extends Table[TradeBid](tag, "trade_bids") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def amount = column[BigDecimal]("amount")
  def placedAt = column[LocalDateTime]("placed_at")
  def isWinning = column[Boolean]("is_winning")
  def listingId = column[Long]("listing_id")
  // cross-context FK to Player (external context — no local table)
  def bidderId = column[Long]("bidder_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, amount, placedAt, isWinning, listingId, bidderId, createdAt, updatedAt).mapTo[TradeBid]
}

object TradeBidRepository {
  val table = TableQuery[TradeBidTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[TradeBid]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[TradeBid]] =
    table.filter(_.id === id).result.headOption

  def create(item: TradeBid): DBIO[TradeBid] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

}
