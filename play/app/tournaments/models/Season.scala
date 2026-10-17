package cards_project.tournaments.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait SeasonFormatType
object SeasonFormatType {
  case object STANDARD extends SeasonFormatType
  case object EXTENDED extends SeasonFormatType
  case object LEGACY extends SeasonFormatType
  case object VINTAGE extends SeasonFormatType
  case object COMMANDER extends SeasonFormatType
  case object DRAFT extends SeasonFormatType
  val values: Seq[SeasonFormatType] = Seq(STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT)
  def fromString(s: String): SeasonFormatType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown SeasonFormatType: $s"))
  implicit val format: Format[SeasonFormatType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Season(
  id: Option[Long] = None,
  name: String,
  startDate: java.time.LocalDate,
  endDate: java.time.LocalDate,
  format: String = "STANDARD",
  isActive: Boolean = false,
  rewardDescription: Option[String] = None,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Season {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Season] = Json.format[Season]
}

class SeasonTable(tag: Tag) extends Table[Season](tag, "seasons") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def name = column[String]("name")
  def startDate = column[LocalDate]("start_date")
  def endDate = column[LocalDate]("end_date")
  def format = column[String]("format")
  def isActive = column[Boolean]("is_active")
  def rewardDescription = column[Option[String]]("reward_description")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, name, startDate, endDate, format, isActive, rewardDescription, createdAt, updatedAt).mapTo[Season]
}

object SeasonRepository {
  val table = TableQuery[SeasonTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Season]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.name.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[Season]] =
    table.filter(_.id === id).result.headOption

  def create(item: Season): DBIO[Season] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: Season)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Season]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

}
