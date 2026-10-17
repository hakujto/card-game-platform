package cards_project.players.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait PlayerRankType
object PlayerRankType {
  case object BRONZE extends PlayerRankType
  case object SILVER extends PlayerRankType
  case object GOLD extends PlayerRankType
  case object PLATINUM extends PlayerRankType
  case object DIAMOND extends PlayerRankType
  case object MASTER extends PlayerRankType
  case object GRANDMASTER extends PlayerRankType
  val values: Seq[PlayerRankType] = Seq(BRONZE, SILVER, GOLD, PLATINUM, DIAMOND, MASTER, GRANDMASTER)
  def fromString(s: String): PlayerRankType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown PlayerRankType: $s"))
  implicit val format: Format[PlayerRankType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait PlayerPreferredFormatType
object PlayerPreferredFormatType {
  case object STANDARD extends PlayerPreferredFormatType
  case object EXTENDED extends PlayerPreferredFormatType
  case object LEGACY extends PlayerPreferredFormatType
  case object VINTAGE extends PlayerPreferredFormatType
  case object COMMANDER extends PlayerPreferredFormatType
  case object DRAFT extends PlayerPreferredFormatType
  val values: Seq[PlayerPreferredFormatType] = Seq(STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT)
  def fromString(s: String): PlayerPreferredFormatType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown PlayerPreferredFormatType: $s"))
  implicit val format: Format[PlayerPreferredFormatType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Player(
  id: Option[Long] = None,
  publicId: String,
  displayName: String,
  rank: String = "BRONZE",
  rating: Int = 1000,
  peakRating: Int = 1000,
  bio: Option[String] = None,
  countryCode: Option[String] = None,
  avatarUrl: Option[String] = None,
  preferredFormat: Option[String] = None,
  contactEmail: Option[String] = None,
  winRateCached: Option[Double] = None,
  isVerified: Boolean = false,
  lastActiveAt: Option[java.time.LocalDateTime] = None,
  userId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Player {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Player] = Json.format[Player]
}

class PlayerTable(tag: Tag) extends Table[Player](tag, "players") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def publicId = column[String]("public_id", O.Unique)
  def displayName = column[String]("display_name", O.Unique)
  def rank = column[String]("rank")
  def rating = column[Int]("rating")
  def peakRating = column[Int]("peak_rating")
  def bio = column[Option[String]]("bio")
  def countryCode = column[Option[String]]("country_code")
  def avatarUrl = column[Option[String]]("avatar_url")
  def preferredFormat = column[Option[String]]("preferred_format")
  def contactEmail = column[Option[String]]("contact_email")
  def winRateCached = column[Option[Double]]("win_rate_cached")
  def isVerified = column[Boolean]("is_verified")
  def lastActiveAt = column[Option[LocalDateTime]]("last_active_at")
  // cross-context FK to User (external context — no local table)
  def userId = column[Long]("user_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, publicId, displayName, rank, rating, peakRating, bio, countryCode, avatarUrl, preferredFormat, contactEmail, winRateCached, isVerified, lastActiveAt, userId, createdAt, updatedAt).mapTo[Player]
}

object PlayerRepository {
  val table = TableQuery[PlayerTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Player]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.displayName.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[Player]] =
    table.filter(_.id === id).result.headOption

  def create(item: Player): DBIO[Player] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: Player)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Player]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def patch(id: Long, fields: Map[String, JsValue])(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Player]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(
          bio = fields.get("bio").flatMap(_.asOpt[String]).orElse(existing.bio),
          countryCode = fields.get("country_code").flatMap(_.asOpt[String]).orElse(existing.countryCode),
          avatarUrl = fields.get("avatar_url").flatMap(_.asOpt[String]).orElse(existing.avatarUrl),
          preferredFormat = fields.get("preferred_format").flatMap(_.asOpt[String]).orElse(existing.preferredFormat)
        )
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}
