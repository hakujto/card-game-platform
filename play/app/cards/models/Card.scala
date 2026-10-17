package cards_project.cards.models

import play.api.libs.json._
import slick.jdbc.H2Profile.api._
import java.time.{LocalDate, LocalDateTime}

sealed trait CardCardTypeType
object CardCardTypeType {
  case object CREATURE extends CardCardTypeType
  case object SPELL extends CardCardTypeType
  case object LAND extends CardCardTypeType
  case object ARTIFACT extends CardCardTypeType
  case object ENCHANTMENT extends CardCardTypeType
  case object PLANESWALKER extends CardCardTypeType
  val values: Seq[CardCardTypeType] = Seq(CREATURE, SPELL, LAND, ARTIFACT, ENCHANTMENT, PLANESWALKER)
  def fromString(s: String): CardCardTypeType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown CardCardTypeType: $s"))
  implicit val format: Format[CardCardTypeType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait CardRarityType
object CardRarityType {
  case object COMMON extends CardRarityType
  case object UNCOMMON extends CardRarityType
  case object RARE extends CardRarityType
  case object MYTHICRARE extends CardRarityType
  case object LEGENDARY extends CardRarityType
  val values: Seq[CardRarityType] = Seq(COMMON, UNCOMMON, RARE, MYTHICRARE, LEGENDARY)
  def fromString(s: String): CardRarityType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown CardRarityType: $s"))
  implicit val format: Format[CardRarityType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait CardManaColorsType
object CardManaColorsType {
  case object WHITE extends CardManaColorsType
  case object BLUE extends CardManaColorsType
  case object BLACK extends CardManaColorsType
  case object RED extends CardManaColorsType
  case object GREEN extends CardManaColorsType
  case object COLORLESS extends CardManaColorsType
  val values: Seq[CardManaColorsType] = Seq(WHITE, BLUE, BLACK, RED, GREEN, COLORLESS)
  def fromString(s: String): CardManaColorsType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown CardManaColorsType: $s"))
  implicit val format: Format[CardManaColorsType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

sealed trait CardLegalFormatsType
object CardLegalFormatsType {
  case object STANDARD extends CardLegalFormatsType
  case object EXTENDED extends CardLegalFormatsType
  case object LEGACY extends CardLegalFormatsType
  case object VINTAGE extends CardLegalFormatsType
  case object COMMANDER extends CardLegalFormatsType
  case object DRAFT extends CardLegalFormatsType
  val values: Seq[CardLegalFormatsType] = Seq(STANDARD, EXTENDED, LEGACY, VINTAGE, COMMANDER, DRAFT)
  def fromString(s: String): CardLegalFormatsType = values.find(_.toString == s).getOrElse(throw new IllegalArgumentException(s"Unknown CardLegalFormatsType: $s"))
  implicit val format: Format[CardLegalFormatsType] = Format(
    Reads { js => js.validate[String].map(fromString) },
    Writes { v => JsString(v.toString) }
  )
}

case class Card(
  id: Option[Long] = None,
  publicId: String,
  name: String,
  cardType: String = "CREATURE",
  rarity: String = "COMMON",
  manaCost: Int = 0,
  manaColors: String,
  attack: Option[Int] = None,
  defense: Option[Int] = None,
  loyalty: Option[Int] = None,
  description: String,
  flavorText: Option[String] = None,
  imageUrl: Option[String] = None,
  artistName: Option[String] = None,
  legalFormats: String,
  isBanned: Boolean = false,
  isRestricted: Boolean = false,
  powerLevel: Int = 1,
  metadata: Option[String] = None,
  totalCopiesInCirculation: Long = 0L,
  setId: Long,
  createdAt: Option[LocalDateTime] = None,
  updatedAt: Option[LocalDateTime] = None
)

object Card {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[Card] = Json.format[Card]
}

class CardTable(tag: Tag) extends Table[Card](tag, "cards") {
  def id        = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def publicId = column[String]("public_id", O.Unique)
  def name = column[String]("name")
  def cardType = column[String]("card_type")
  def rarity = column[String]("rarity")
  def manaCost = column[Int]("mana_cost")
  def manaColors = column[String]("mana_colors")
  def attack = column[Option[Int]]("attack")
  def defense = column[Option[Int]]("defense")
  def loyalty = column[Option[Int]]("loyalty")
  def description = column[String]("description")
  def flavorText = column[Option[String]]("flavor_text")
  def imageUrl = column[Option[String]]("image_url")
  def artistName = column[Option[String]]("artist_name")
  def legalFormats = column[String]("legal_formats")
  def isBanned = column[Boolean]("is_banned")
  def isRestricted = column[Boolean]("is_restricted")
  def powerLevel = column[Int]("power_level")
  def metadata = column[Option[String]]("metadata")
  def totalCopiesInCirculation = column[Long]("total_copies_in_circulation")
  def setId = column[Long]("set_id")
  def createdAt = column[Option[LocalDateTime]]("created_at")
  def updatedAt = column[Option[LocalDateTime]]("updated_at")

  def * = ((id.?, publicId, name, cardType, rarity, manaCost, manaColors, attack, defense, loyalty, description, flavorText, imageUrl, artistName, legalFormats, isBanned, isRestricted, powerLevel, metadata, totalCopiesInCirculation, setId, createdAt), (updatedAt)).shaped.<>(
    { case ((_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22), (_23)) => Card.apply(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23) },
    (p: Card) => Some(((p.id, p.publicId, p.name, p.cardType, p.rarity, p.manaCost, p.manaColors, p.attack, p.defense, p.loyalty, p.description, p.flavorText, p.imageUrl, p.artistName, p.legalFormats, p.isBanned, p.isRestricted, p.powerLevel, p.metadata, p.totalCopiesInCirculation, p.setId, p.createdAt), (p.updatedAt)))
  )
}

object CardRepository {
  val table = TableQuery[CardTable]

  def list(skip: Int = 0, limit: Int = 100, q: Option[String] = None): DBIO[Seq[Card]] = {
    q match {
      case Some(query) =>
        table.filter(row => row.name.like("%" + query + "%") || row.artistName.like("%" + query + "%")).drop(skip).take(limit).result
      case None =>
        table.drop(skip).take(limit).result
    }
  }

  def findById(id: Long): DBIO[Option[Card]] =
    table.filter(_.id === id).result.headOption

  def create(item: Card): DBIO[Card] =
    (table returning table.map(_.id) into ((row, id) => row.copy(id = Some(id)))) += item

  def update(id: Long, item: Card)(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Card]] =
    table.filter(_.id === id).update(item.copy(id = Some(id))).flatMap {
      case 0 => DBIO.successful(None)
      case _ => findById(id)
    }

  def patch(id: Long, fields: Map[String, JsValue])(implicit ec: scala.concurrent.ExecutionContext): DBIO[Option[Card]] =
    findById(id).flatMap {
      case None => DBIO.successful(None)
      case Some(existing) =>
        val updated = existing.copy(
          flavorText = fields.get("flavor_text").flatMap(_.asOpt[String]).orElse(existing.flavorText),
          artistName = fields.get("artist_name").flatMap(_.asOpt[String]).orElse(existing.artistName)
        )
        table.filter(_.id === id).update(updated).map(_ => Some(updated))
    }

}

case class CardAuditLog(
  id: Option[Long] = None,
  recordId: Long,
  field: String,
  oldValue: Option[String] = None,
  newValue: Option[String] = None,
  changedAt: Option[LocalDateTime] = None
)

object CardAuditLog {
  implicit val config: JsonConfiguration = JsonConfiguration(JsonNaming.SnakeCase)
  implicit val format: OFormat[CardAuditLog] = Json.format[CardAuditLog]
}
