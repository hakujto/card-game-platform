package cards_project.cards.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait CardSetSetTypeType
object CardSetSetTypeType {
  case object CORE extends CardSetSetTypeType
  case object EXPANSION extends CardSetSetTypeType
  case object SUPPLEMENTAL extends CardSetSetTypeType
  case object MASTERS extends CardSetSetTypeType
  case object DRAFT extends CardSetSetTypeType
  val values: Seq[CardSetSetTypeType] = Seq(CORE, EXPANSION, SUPPLEMENTAL, MASTERS, DRAFT)
  def fromString(s: String): CardSetSetTypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown CardSetSetTypeType: $s"))
  implicit val format: Format[CardSetSetTypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class CardSet(
  id: Option[Long] = None,
  name: String,
  code: String,
  releaseDate: java.time.LocalDate,
  rotationDate: Option[java.time.LocalDate] = None,
  setType: String = "EXPANSION",
  totalCards: Int,
  isRotated: Boolean = false,
  description: Option[String] = None,
  logoUrl: Option[String] = None,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object CardSet {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[CardSet] = Json.format[CardSet]
}

class CardSetTable(tag: Tag) extends Table[CardSet](tag, "card_sets") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def name = column[String]("name")
  def code = column[String]("code", O.Unique)
  def releaseDate = column[LocalDate]("release_date")
  def rotationDate = column[Option[LocalDate]]("rotation_date")
  def setType = column[String]("set_type")
  def totalCards = column[Int]("total_cards")
  def isRotated = column[Boolean]("is_rotated")
  def description = column[Option[String]]("description")
  def logoUrl = column[Option[String]]("logo_url")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, name, code, releaseDate, rotationDate, setType, totalCards, isRotated, description, logoUrl, createdAt, updatedAt).mapTo[CardSet]
}

object CardSetRepository {
  val table = TableQuery[CardSetTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[CardSet]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.name.like("%" + query + "%") || row.code.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[CardSet]] =
    table.filter(_.id === id).result.headOption

  def create(item: CardSet): DBIO[CardSet] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: CardSet)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[CardSet]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

}
