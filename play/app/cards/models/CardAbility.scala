package cards_project.cards.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait CardAbilityAbilityTypeType
object CardAbilityAbilityTypeType {
  case object KEYWORD extends CardAbilityAbilityTypeType
  case object ACTIVATED extends CardAbilityAbilityTypeType
  case object TRIGGERED extends CardAbilityAbilityTypeType
  case object STATIC extends CardAbilityAbilityTypeType
  val values: Seq[CardAbilityAbilityTypeType] = Seq(KEYWORD, ACTIVATED, TRIGGERED, STATIC)
  def fromString(s: String): CardAbilityAbilityTypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown CardAbilityAbilityTypeType: $s"))
  implicit val format: Format[CardAbilityAbilityTypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait CardAbilityTimingType
object CardAbilityTimingType {
  case object ANY extends CardAbilityTimingType
  case object SORCERY extends CardAbilityTimingType
  case object INSTANT extends CardAbilityTimingType
  case object COMBAT extends CardAbilityTimingType
  val values: Seq[CardAbilityTimingType] = Seq(ANY, SORCERY, INSTANT, COMBAT)
  def fromString(s: String): CardAbilityTimingType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown CardAbilityTimingType: $s"))
  implicit val format: Format[CardAbilityTimingType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class CardAbility(
  id: Option[Long] = None,
  abilityType: String = "KEYWORD",
  keyword: Option[String] = None,
  abilityText: String,
  timing: Option[String] = None,
  cardId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object CardAbility {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[CardAbility] = Json.format[CardAbility]
}

class CardAbilityTable(tag: Tag) extends Table[CardAbility](tag, "card_abilities") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def abilityType = column[String]("ability_type")
  def keyword = column[Option[String]]("keyword")
  def abilityText = column[String]("ability_text")
  def timing = column[Option[String]]("timing")
  def cardId = column[Long]("card_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = (id.?, abilityType, keyword, abilityText, timing, cardId, createdAt, updatedAt).mapTo[CardAbility]
}

object CardAbilityRepository {
  val table = TableQuery[CardAbilityTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[CardAbility]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.keyword.like("%" + query + "%") || row.abilityText.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[CardAbility]] =
    table.filter(_.id === id).result.headOption

  def create(item: CardAbility): DBIO[CardAbility] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: CardAbility)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[CardAbility]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def delete(id: Long)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Boolean] =
    table.filter(_.id === id).delete.map(_ > 0)

}
