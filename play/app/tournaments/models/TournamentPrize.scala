package cards_project.tournaments.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait TournamentPrizePrizeTypeType
object TournamentPrizePrizeTypeType {
  case object CURRENCY extends TournamentPrizePrizeTypeType
  case object CARDS extends TournamentPrizePrizeTypeType
  case object BOOSTERPACKS extends TournamentPrizePrizeTypeType
  case object TROPHY extends TournamentPrizePrizeTypeType
  case object SEASONPOINTS extends TournamentPrizePrizeTypeType
  case object MIXED extends TournamentPrizePrizeTypeType
  val values: Seq[TournamentPrizePrizeTypeType] = Seq(CURRENCY, CARDS, BOOSTERPACKS, TROPHY, SEASONPOINTS, MIXED)
  def fromString(s: String): TournamentPrizePrizeTypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown TournamentPrizePrizeTypeType: $s"))
  implicit val format: Format[TournamentPrizePrizeTypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class TournamentPrize(
  id: Option[Long] = None,
  placementFrom: Int,
  placementTo: Int,
  prizeType: String,
  amount: BigDecimal = 0,
  description: Option[String] = None,
  packsCount: Option[Int] = None,
  seasonPoints: Int = 0,
  tournamentId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object TournamentPrize {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[TournamentPrize] = Json.format[TournamentPrize]
}

class TournamentPrizeTable(tag: Tag) extends Table[TournamentPrize](tag, "tournament_prizes") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def placementFrom = column[Int]("placement_from")
  def placementTo = column[Int]("placement_to")
  def prizeType = column[String]("prize_type")
  def amount = column[BigDecimal]("amount")
  def description = column[Option[String]]("description")
  def packsCount = column[Option[Int]]("packs_count")
  def seasonPoints = column[Int]("season_points")
  def tournamentId = column[Long]("tournament_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, placementFrom, placementTo, prizeType, amount, description, packsCount, seasonPoints, tournamentId, createdAt, updatedAt).mapTo[TournamentPrize]
}

object TournamentPrizeRepository {
  val table = TableQuery[TournamentPrizeTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[TournamentPrize]] = {
    table.drop(skip).take(limit).result
  }

  def findById(id: Long): DBIO[Option[TournamentPrize]] =
    table.filter(_.id === id).result.headOption

  def create(item: TournamentPrize): DBIO[TournamentPrize] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: TournamentPrize)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[TournamentPrize]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
