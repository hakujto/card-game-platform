package cards_project.marketplace.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

case class CardPriceHistory(
  id: Option[Long] = None,
  priceDate: java.time.LocalDate,
  avgPrice: BigDecimal,
  minPrice: BigDecimal,
  maxPrice: BigDecimal,
  volume: Int,
  foil: Boolean = false,
  cardId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object CardPriceHistory {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[CardPriceHistory] = Json.format[CardPriceHistory]
}

class CardPriceHistoryTable(tag: Tag) extends Table[CardPriceHistory](tag, "card_price_histories") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def priceDate = column[LocalDate]("price_date")
  def avgPrice = column[BigDecimal]("avg_price")
  def minPrice = column[BigDecimal]("min_price")
  def maxPrice = column[BigDecimal]("max_price")
  def volume = column[Int]("volume")
  def foil = column[Boolean]("foil")
  // cross-context FK to Card (external context — no local table)
  def cardId = column[Long]("card_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, priceDate, avgPrice, minPrice, maxPrice, volume, foil, cardId, createdAt, updatedAt).mapTo[CardPriceHistory]
}

object CardPriceHistoryRepository {
  val table = TableQuery[CardPriceHistoryTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[CardPriceHistory]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[CardPriceHistory]] =
    table.filter(_.id === id).result.headOption

}
