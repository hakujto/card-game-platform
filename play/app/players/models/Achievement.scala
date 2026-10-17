package cards_project.players.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait AchievementRarityType
object AchievementRarityType {
  case object COMMON extends AchievementRarityType
  case object UNCOMMON extends AchievementRarityType
  case object RARE extends AchievementRarityType
  case object EPIC extends AchievementRarityType
  case object LEGENDARY extends AchievementRarityType
  val values: Seq[AchievementRarityType] = Seq(COMMON, UNCOMMON, RARE, EPIC, LEGENDARY)
  def fromString(s: String): AchievementRarityType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown AchievementRarityType: $s"))
  implicit val format: Format[AchievementRarityType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Achievement(
  id: Option[Long] = None,
  name: String,
  description: String,
  iconUrl: Option[String] = None,
  points: Int = 10,
  rarity: String = "COMMON",
  isHidden: Boolean = false,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Achievement {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Achievement] = Json.format[Achievement]
}

class AchievementTable(tag: Tag) extends Table[Achievement](tag, "achievements") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def name = column[String]("name")
  def description = column[String]("description")
  def iconUrl = column[Option[String]]("icon_url")
  def points = column[Int]("points")
  def rarity = column[String]("rarity")
  def isHidden = column[Boolean]("is_hidden")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, name, description, iconUrl, points, rarity, isHidden, createdAt, updatedAt).mapTo[Achievement]
}

object AchievementRepository {
  val table = TableQuery[AchievementTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Achievement]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.name.like("%" + query + "%") || row.description.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[Achievement]] =
    table.filter(_.id === id).result.headOption

  def create(item: Achievement): DBIO[Achievement] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: Achievement)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Achievement]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

}
